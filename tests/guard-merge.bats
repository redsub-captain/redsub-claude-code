#!/usr/bin/env bats
# Tests for guard-merge.sh — CI status check before gh pr merge

setup() {
  SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts" && pwd)"
  FIXTURE_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"
  SCRIPT="$SCRIPT_DIR/guard-merge.sh"
}

# Helper: create hook stdin JSON with a command
make_input() {
  printf '{"tool_name":"Bash","input":{"command":"%s"}}' "$1"
}

# Helper: create mock gh that returns fixture data
setup_mock_gh() {
  local fixture="$1"
  MOCK_DIR="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$MOCK_DIR"
  cat > "$MOCK_DIR/gh" <<MOCK
#!/usr/bin/env bash
cat "$fixture"
MOCK
  chmod +x "$MOCK_DIR/gh"
  export PATH="$MOCK_DIR:$PATH"
}

# Helper: create mock gh that fails
setup_mock_gh_fail() {
  MOCK_DIR="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$MOCK_DIR"
  cat > "$MOCK_DIR/gh" <<'MOCK'
#!/usr/bin/env bash
echo "error: could not connect" >&2
exit 1
MOCK
  chmod +x "$MOCK_DIR/gh"
  export PATH="$MOCK_DIR:$PATH"
}

# Helper: hide gh from PATH
setup_no_gh() {
  MOCK_DIR="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$MOCK_DIR"
  export PATH="$MOCK_DIR:/usr/bin:/bin"
}

# --- Tests ---

@test "non-merge command exits 0 silently" {
  run bash -c "printf '%s' '$(make_input "ls -la")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git merge command is ignored (handled by guard-main)" {
  run bash -c "printf '%s' '$(make_input "git merge main")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "all checks passing exits 0 silently" {
  setup_mock_gh "$FIXTURE_DIR/checks-all-pass.json"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "gh pr merge 42 --squash")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "failing checks exits 2 with BLOCKED message" {
  setup_mock_gh "$FIXTURE_DIR/checks-failing.json"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "gh pr merge 42")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
  [[ "$output" == *"1 check(s)"* ]]
  [[ "$output" == *"test"* ]]
}

@test "pending checks exits 0 with WARNING message" {
  setup_mock_gh "$FIXTURE_DIR/checks-pending.json"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "gh pr merge 42")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING"* ]]
  [[ "$output" == *"2 check(s)"* ]]
}

@test "mixed fail+pending exits 2 (failure takes priority)" {
  setup_mock_gh "$FIXTURE_DIR/checks-mixed.json"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "gh pr merge 42")' | '$SCRIPT'"
  [ "$status" -eq 2 ]
  [[ "$output" == *"BLOCKED"* ]]
}

@test "empty checks (no CI configured) exits 0 silently" {
  setup_mock_gh "$FIXTURE_DIR/checks-empty.json"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "gh pr merge 42")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "gh CLI not found exits 0 with warning" {
  setup_no_gh
  run bash -c "export PATH='$MOCK_DIR:/usr/bin:/bin'; printf '%s' '$(make_input "gh pr merge 42")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING"* ]]
  [[ "$output" == *"gh CLI"* ]]
}

@test "network failure exits 0 with warning" {
  setup_mock_gh_fail
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "gh pr merge 42")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING"* ]]
  [[ "$output" == *"Proceeding"* ]]
}

@test "gh pr merge without PR number works" {
  setup_mock_gh "$FIXTURE_DIR/checks-all-pass.json"
  run bash -c "export PATH='$MOCK_DIR:$PATH'; printf '%s' '$(make_input "gh pr merge --squash")' | '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
