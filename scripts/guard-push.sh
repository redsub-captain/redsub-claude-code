#!/usr/bin/env bash
# [PreToolUse:Bash] Block feature branch push + PR creation (solo workflow)
# Solo workflow: local branch → local merge to main → push only main
# exit 2 = block tool execution in Claude Code

set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Read JSON input from stdin
INPUT=$(cat)

# Extract command
COMMAND=$(json_input_val "$INPUT" "" input command)

# --- Block gh pr create ---
if echo "$COMMAND" | grep -qE 'gh[[:space:]]+pr[[:space:]]+create'; then
  echo "BLOCKED: Solo workflow — PRs are not used. Merge locally and push main instead."
  exit 2
fi

# --- Only check git push commands ---
if ! echo "$COMMAND" | grep -qE 'git[[:space:]]+push'; then
  exit 0
fi

# Extract push target: parse the branch/refspec from git push command
# Patterns: git push origin main, git push -u origin feature/x, git push --tags, git push
PUSH_TARGET=""

# Remove flags (-u, --set-upstream, --force, --tags, etc.) and find remote + ref
ARGS=$(echo "$COMMAND" | sed -E 's/git[[:space:]]+push[[:space:]]*//' | sed -E 's/-(u|-set-upstream|-force|-no-verify|f)[[:space:]]*//g')

# Extract positional args (remote and ref)
REMOTE=""
REF=""
for arg in $ARGS; do
  # Skip --tags and other -- flags
  if [[ "$arg" == --* ]]; then
    continue
  fi
  if [ -z "$REMOTE" ]; then
    REMOTE="$arg"
  elif [ -z "$REF" ]; then
    REF="$arg"
  fi
done

# If we have an explicit ref, check it
if [ -n "$REF" ]; then
  PUSH_TARGET="$REF"
elif [ -n "$REMOTE" ] && [ "$REMOTE" != "origin" ] && ! [[ "$REMOTE" == --* ]]; then
  # Could be: git push origin (no ref) or git push main (no remote, unlikely)
  # If REMOTE looks like a branch name (not a typical remote name), treat as ref
  PUSH_TARGET="$REMOTE"
fi

# If explicit target is main/master, allow
if [ -n "$PUSH_TARGET" ]; then
  if [ "$PUSH_TARGET" = "main" ] || [ "$PUSH_TARGET" = "master" ]; then
    exit 0
  fi
  # Explicit non-main target — block
  echo "BLOCKED: Solo workflow — only 'main' can be pushed to remote. Merge locally first, then push main."
  exit 2
fi

# No explicit target: check current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  exit 0
fi

echo "BLOCKED: Solo workflow — only 'main' can be pushed to remote. Merge locally first, then push main."
exit 2
