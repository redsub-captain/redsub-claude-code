#!/usr/bin/env bash
# redsub-claude-code shared library
# Usage: source "$(dirname "$0")/lib.sh"

# --- State directory (replaces /tmp for session markers) ---
REDSUB_DIR="$HOME/.claude-redsub"
mkdir -p "$REDSUB_DIR" 2>/dev/null || true

# --- JSON Utilities (jq preferred, python3 fallback) ---

# json_val FILE KEY [KEY2 ...]
# Read nested value from a JSON file.
# Keys that are pure digits are treated as array indices.
# Example: json_val package.json version
# Example: json_val marketplace.json plugins 0 version
json_val() {
  local file="$1"; shift
  if command -v jq &>/dev/null; then
    local expr=""
    for k in "$@"; do
      if [[ "$k" =~ ^[0-9]+$ ]]; then
        expr="${expr}[$k]"
      else
        expr="${expr}.${k}"
      fi
    done
    [ -z "$expr" ] && expr="."
    jq -r "$expr // empty" "$file" 2>/dev/null || echo ""
  else
    python3 - "$file" "$@" <<'PYEOF' 2>/dev/null || echo ""
import json, sys
data = json.load(open(sys.argv[1]))
for key in sys.argv[2:]:
    try: data = data[key]
    except (KeyError, TypeError):
        try: data = data[int(key)]
        except (ValueError, IndexError, TypeError): print(""); sys.exit(0)
print(data)
PYEOF
  fi
}

# json_count FILE [KEY ...]
# Count elements in a JSON array or object.
# Example: json_count plugins.json plugins  →  len(.plugins)
# Example: json_count file.json              →  len(root)
json_count() {
  local file="$1"; shift
  if command -v jq &>/dev/null; then
    local expr=""
    for k in "$@"; do expr="${expr}.${k}"; done
    [ -z "$expr" ] && expr="."
    jq "${expr} | length" "$file" 2>/dev/null || echo "0"
  else
    python3 - "$file" "$@" <<'PYEOF' 2>/dev/null || echo "0"
import json, sys
data = json.load(open(sys.argv[1]))
for key in sys.argv[2:]: data = data[key]
print(len(data))
PYEOF
  fi
}

# json_input_val JSON_STRING DEFAULT KEY [KEY2 ...]
# Read nested value from a JSON string (hook stdin input).
# Returns DEFAULT if the key path doesn't exist.
# Example: json_input_val "$INPUT" "" input command
# Example: json_input_val "$INPUT" "1" output exitCode
json_input_val() {
  local json="$1" default="$2"; shift 2
  if command -v jq &>/dev/null; then
    local expr=""
    for k in "$@"; do expr="${expr}.${k}"; done
    [ -z "$expr" ] && expr="."
    local result
    result=$(echo "$json" | jq -r "${expr} // empty" 2>/dev/null) || true
    echo "${result:-$default}"
  else
    echo "$json" | python3 - "$default" "$@" <<'PYEOF' 2>/dev/null || echo "$default"
import json, sys
data = json.load(sys.stdin)
default = sys.argv[1]
for key in sys.argv[2:]:
    if isinstance(data, dict):
        data = data.get(key, None)
    else:
        data = None
        break
if data is None or (isinstance(data, dict) and not data):
    data = default
print(data)
PYEOF
  fi
}

# json_set_version FILE NEW_VERSION
# Update the .version field in a JSON file (atomic write).
json_set_version() {
  local file="$1" version="$2"
  if command -v jq &>/dev/null; then
    local tmp
    tmp=$(mktemp)
    if jq --arg v "$version" '.version = $v' "$file" > "$tmp" 2>/dev/null; then
      mv "$tmp" "$file"
    else
      rm -f "$tmp"
      return 1
    fi
  else
    python3 - "$file" "$version" <<'PYEOF' 2>/dev/null || return 1
import json, sys
with open(sys.argv[1]) as f: data = json.load(f)
data['version'] = sys.argv[2]
with open(sys.argv[1], 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
PYEOF
  fi
}

# json_valid FILE
# Returns 0 if valid JSON, non-zero otherwise.
json_valid() {
  if command -v jq &>/dev/null; then
    jq empty "$1" 2>/dev/null
  else
    python3 -m json.tool "$1" > /dev/null 2>&1
  fi
}

# json_list_field FILE ARRAY_KEY FIELD_KEY
# Print each element's field from an array.
# Example: json_list_field plugins.json plugins name
json_list_field() {
  local file="$1" array_key="$2" field_key="$3"
  if command -v jq &>/dev/null; then
    jq -r ".${array_key}[].${field_key}" "$file" 2>/dev/null
  else
    python3 - "$file" "$array_key" "$field_key" <<'PYEOF' 2>/dev/null
import json, sys
data = json.load(open(sys.argv[1]))
for item in data[sys.argv[2]]:
    print(item[sys.argv[3]])
PYEOF
  fi
}

# --- Cross-platform utilities ---

# file_mtime FILE → epoch seconds (detects OS once)
file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}

# safe_osascript TITLE MESSAGE
# macOS notification with proper escaping to prevent AppleScript injection.
safe_osascript() {
  command -v osascript &>/dev/null || return 0
  local title="$1" message="$2"
  title="${title//\\/\\\\}"
  title="${title//\"/\\\"}"
  message="${message//\\/\\\\}"
  message="${message//\"/\\\"}"
  osascript -e "display notification \"${message}\" with title \"${title}\"" 2>/dev/null || true
}

# --- Session marker utilities ---

# Clean all session markers (call on SessionStart)
clean_session_markers() {
  rm -f "$REDSUB_DIR"/claude-md-revised \
       "$REDSUB_DIR"/edit-count \
       "$REDSUB_DIR"/component-count 2>/dev/null || true
}
