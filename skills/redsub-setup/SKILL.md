---
name: redsub-setup
description: Initial plugin setup. Register plugins, permissions, create CLAUDE.md.
---

# Initial Setup

## Re-run prevention

If `~/.claude-redsub/.setup-done` exists and `--force` was NOT given in `$ARGUMENTS`, print "Already configured. Use --force to re-run." and stop.

## Procedure

### 1. Run setup-core.sh

Execute the core setup script that handles everything automatically with zero user input -- dependency check (SSOT: `config/plugins.json`), plugin registration (`register-plugins.sh`), permission registration (`register-permissions.sh`), CLAUDE.md creation/update (`merge-template.sh`), manifest creation, and completion marker in a single call:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-core.sh" "${CLAUDE_PLUGIN_ROOT}" [--force if given]
```

Parse the JSON output. The result has this structure:
```json
{
  "status": "completed | already_configured",
  "dependencies": {"total": 12, "installed": 12, "missing": []},
  "permissions": {"total": 16, "registered": 16, "missing": []},
  "manifest_updated": true,
  "version": "X.X.X",
  "claude_md": {"status": "missing | no_markers | has_markers", "template_version": "X.X.X", "template_latest": "X.X.X"}
}
```

If `status` = `"already_configured"`: print the message and stop.

### 2. Install missing plugins (if any)

If `dependencies.missing` is not empty:

Use `AskUserQuestion`:
- question: "[N] missing plugin(s) found. Auto-install?"
- header: "Plugins"
- options: ["Install all (Recommended)", "Skip for now"]

If user chooses install: run each missing plugin install sequentially via Bash:
```bash
claude plugin install <name>@<marketplace>
```
Show progress as each plugin installs. If any single install fails, log the error and continue.

If user chooses skip: continue to the next step.

### 3. Register missing permissions (if any)

If `permissions.missing` is not empty:

Use `AskUserQuestion`:
- question: "[N] permission(s) needed for plugin workflows. Registering in ~/.claude/settings.json reduces repeated Allow prompts. Register?"
- header: "Permissions"
- options: ["Register all (Recommended)" (register all patterns), "Show details first" (list all patterns then ask again), "Skip" (do not modify permissions)]

If user chooses "Show details first": print all missing patterns, then re-ask with just "Register all" / "Skip".

If user chooses "Register all", run the register script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/register-permissions.sh" "${CLAUDE_PLUGIN_ROOT}" [missing patterns...]
```
Parse the JSON output. Report: "[N] permission(s) registered."

### 4. CLAUDE.md handling

Based on `claude_md.status` from the JSON result:

**If `"missing"`**: Create `~/.claude/CLAUDE.md` from template:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/merge-template.sh" "${CLAUDE_PLUGIN_ROOT}" create
```

**If `"no_markers"`**: Existing file without plugin markers.
Use `AskUserQuestion`:
- question: "~/.claude/CLAUDE.md already exists. How should the workflow guide be added?"
- header: "CLAUDE.md"
- options: ["Append at end (Recommended)", "Prepend at start", "Skip"]

If not "Skip", run the merge script with the chosen mode:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/merge-template.sh" "${CLAUDE_PLUGIN_ROOT}" append
# or: prepend
```

**If `"has_markers"`**: Existing file with markers.
- If `template_version` = `template_latest`: report "CLAUDE.md already up to date (vX.X.X)" and skip.
- If versions differ: Use `AskUserQuestion`:
  - question: "Update CLAUDE.md template? (current: [template_version or 'legacy'] → latest: [template_latest]). User customizations are preserved."
  - header: "CLAUDE.md"
  - options: ["Update (Recommended)", "Skip"]
  - If "Update", run:
    ```bash
    bash "${CLAUDE_PLUGIN_ROOT}/scripts/merge-template.sh" "${CLAUDE_PLUGIN_ROOT}" merge
    ```

### 5. Summary

```
Setup complete:
- Plugins: [installed]/[total] registered (12 plugins with superpowers + coderabbit)
- Permissions: [registered/total] in ~/.claude/settings.json
- CLAUDE.md: [created / updated / skipped]
- Legacy rules: cleaned up
- Install manifest: updated
```

If there are still missing plugins (user skipped or some failed), append:
```
Missing plugins ([N]):
  claude plugin install <name>@<marketplace>
  ...
```
