#!/usr/bin/env bats
# Tests for guard-push.sh — Block feature branch push + PR creation (solo workflow)

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts" && pwd)"
  SCRIPT="$SCRIPT_DIR/guard-push.sh"
}

# Helper: create hook stdin JSON with a command
make_input() {
  printf '{"tool_name":"Bash","input":{"command":"%s"}}' "$1"
}

# Helper: mock git to return a specific branch name
setup_mock_git() {
  local branch="$1"
  MOCK_DIR="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$MOCK_DIR"
  cat > "$MOCK_DIR/git" <<MOCK
#!/usr/bin/env bash
if [[ "\$1" == "rev-parse" && "\$2" == "--abbrev-ref" ]]; then
  echo "$branch"
  exit 0
fi
# Pass through for other git commands
command git "\$@"
MOCK
  chmod +x "$MOCK_DIR/git"
  export PATH="$MOCK_DIR:$PATH"
}

# --- Non-push commands (should pass through) ---

@test "non-push command exits 0 silently" {
  run bash -c "printf '%s' '$(make_input "ls -la")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git commit command exits 0 silently" {
  run bash -c "printf '%s' '$(make_input "git commit -m test")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- Allowed push commands ---

@test "git push origin main exits 0" {
  run bash -c "printf '%s' '$(make_input "git push origin main")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git push origin main --tags exits 0" {
  run bash -c "printf '%s' '$(make_input "git push origin main --tags")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git push origin master exits 0" {
  run bash -c "printf '%s' '$(make_input "git push origin master")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git push --tags on main branch exits 0" {
  setup_mock_git "main"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "git push --tags")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

# --- Blocked push commands ---

@test "git push origin feature/xxx exits 2 with BLOCKED" {
  run bash -c "printf '%s' '$(make_input "git push origin feature/xxx")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
  [[ "$output" == *"Solo workflow"* ]]
}

@test "git push -u origin feature/xxx exits 2 with BLOCKED" {
  run bash -c "printf '%s' '$(make_input "git push -u origin feature/xxx")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
}

@test "git push origin fix/bug exits 2 with BLOCKED" {
  run bash -c "printf '%s' '$(make_input "git push origin fix/bug")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
}

@test "bare git push on main branch exits 0" {
  setup_mock_git "main"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "git push")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "bare git push on feature branch exits 2 with BLOCKED" {
  setup_mock_git "feature/solo-workflow"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "git push")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
}

# --- PR creation blocked ---

@test "gh pr create exits 2 with BLOCKED" {
  run bash -c "printf '%s' '$(make_input "gh pr create")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
  [[ "$output" == *"PR"* ]]
}

@test "gh pr create with args exits 2 with BLOCKED" {
  run bash -c "printf '%s' '$(make_input "gh pr create --title test --body desc")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
}
