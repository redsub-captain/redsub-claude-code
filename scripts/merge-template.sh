#!/usr/bin/env bash
# CLAUDE.md Smart Merge — handles all template operations via shell script.
# Eliminates Read/Edit permission prompts by doing everything in Bash.
# Usage: bash merge-template.sh <CLAUDE_PLUGIN_ROOT> <mode>
#   mode: merge    — Smart Merge (preserve user sections, update template)
#         create   — Create new ~/.claude/CLAUDE.md from template
#         append   — Append template to existing file
#         prepend  — Prepend template to existing file
# Output: JSON result on stdout (last line)

set -euo pipefail

source "$(dirname "$0")/lib.sh"

if ! command -v python3 &>/dev/null; then
  echo '{"status":"error","message":"python3 is required for template merge"}'
  exit 1
fi

PLUGIN_ROOT="${1:?Usage: merge-template.sh <CLAUDE_PLUGIN_ROOT> <mode>}"
MODE="${2:?Usage: merge-template.sh <CLAUDE_PLUGIN_ROOT> <mode>}"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
TEMPLATE_FILE="$PLUGIN_ROOT/templates/CLAUDE.md.template"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo '{"status":"error","message":"Template file not found"}'
  exit 1
fi

mkdir -p "$HOME/.claude"

python3 - "$CLAUDE_MD" "$TEMPLATE_FILE" "$MODE" <<'PYEOF'
import json, sys, os, re

claude_md_path = sys.argv[1]
template_path = sys.argv[2]
mode = sys.argv[3]

with open(template_path) as f:
    template = f.read()

MAIN_START = "<!-- redsub-claude-code:start -->"
MAIN_END = "<!-- redsub-claude-code:end -->"
USER_START = "<!-- redsub-user:start -->"
USER_END = "<!-- redsub-user:end -->"

def extract_between(text, start_marker, end_marker):
    """Extract content between two markers (exclusive)."""
    s = text.find(start_marker)
    e = text.find(end_marker)
    if s == -1 or e == -1:
        return None
    return text[s + len(start_marker):e]

def extract_section(text, heading):
    """Extract a ## heading section (heading + body until next ## or end)."""
    pattern = re.compile(r'^(## ' + re.escape(heading[3:].strip()) + r'.*?)(?=^## |\Z)', re.MULTILINE | re.DOTALL)
    m = pattern.search(text)
    return m.group(1).rstrip() + '\n' if m else None

def replace_between(text, start_marker, end_marker, new_content):
    """Replace content between markers (keep markers)."""
    s = text.find(start_marker)
    e = text.find(end_marker)
    if s == -1 or e == -1:
        return text
    return text[:s + len(start_marker)] + new_content + text[e:]

wrapped = f"{MAIN_START}\n{template}\n{MAIN_END}\n"

result = {"status": "success", "action": mode, "message": ""}

try:
    if mode == "create":
        # No existing file — write template wrapped with markers
        with open(claude_md_path, 'w') as f:
            f.write(wrapped)
        result["message"] = "CLAUDE.md created"

    elif mode in ("append", "prepend"):
        existing = ""
        if os.path.exists(claude_md_path):
            with open(claude_md_path) as f:
                existing = f.read()

        if mode == "append":
            content = existing.rstrip() + "\n\n" + wrapped if existing.strip() else wrapped
        else:
            content = wrapped + "\n" + existing if existing.strip() else wrapped

        with open(claude_md_path, 'w') as f:
            f.write(content)
        result["message"] = f"CLAUDE.md {mode}ed"

    elif mode == "merge":
        if not os.path.exists(claude_md_path):
            # No file exists — same as create
            with open(claude_md_path, 'w') as f:
                f.write(wrapped)
            result["action"] = "created"
            result["message"] = "CLAUDE.md created (no existing file)"
        else:
            with open(claude_md_path) as f:
                existing = f.read()

            if MAIN_START not in existing:
                # Case C: No main markers — append
                content = existing.rstrip() + "\n\n" + wrapped
                with open(claude_md_path, 'w') as f:
                    f.write(content)
                result["action"] = "appended"
                result["message"] = "CLAUDE.md appended (no markers found)"
            else:
                # Has main markers — extract user config and merge
                main_content = extract_between(existing, MAIN_START, MAIN_END) or ""

                user_config = None

                # Case A: Sub-markers exist
                if USER_START in main_content and USER_END in main_content:
                    user_config = extract_between(main_content, USER_START, USER_END)

                # Case B: No sub-markers (legacy) — extract sections
                if user_config is None:
                    sections = []
                    tech = extract_section(main_content, "## Tech Stack")
                    if tech:
                        sections.append(tech)
                    progress = extract_section(main_content, "## In progress")
                    if progress:
                        sections.append(progress)
                    if sections:
                        user_config = "\n".join(sections)

                # Build new content
                new_main = template
                if user_config is not None:
                    user_config_stripped = user_config.strip()
                    # Discard default placeholder content
                    if user_config_stripped in ("(none)", "## In progress\n(none)"):
                        user_config_stripped = ""
                    if user_config_stripped:
                        if USER_START in new_main and USER_END in new_main:
                            # Template still has user markers — inject there
                            new_main = replace_between(new_main, USER_START, USER_END, "\n" + user_config_stripped + "\n")
                        else:
                            # Template no longer has user markers — append after template content
                            new_main = new_main.rstrip() + "\n\n" + user_config_stripped + "\n"

                # Replace main markers content in existing file
                new_full = replace_between(existing, MAIN_START, MAIN_END, "\n" + new_main + "\n")
                with open(claude_md_path, 'w') as f:
                    f.write(new_full)
                result["action"] = "merged"
                result["message"] = "CLAUDE.md updated (user sections preserved)"
    else:
        result = {"status": "error", "action": mode, "message": f"Unknown mode: {mode}"}

except Exception as e:
    result = {"status": "error", "action": mode, "message": str(e)}

print(json.dumps(result))
PYEOF
