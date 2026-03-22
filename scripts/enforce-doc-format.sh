#!/usr/bin/env bash
# enforce-doc-format.sh — Add missing required sections to Markdown files.
#
# Usage: enforce-doc-format.sh <file1> [file2] ...
#
# Required sections (prepended if absent):
#   ## Summary
#   ## What I Learned
#   ## Commands
#
# Files under .github/ are always skipped.

set -euo pipefail

for file in "$@"; do
  # Skip if argument is somehow empty
  [ -z "$file" ] && continue

  # Skip files under .github/
  if [[ "$file" == .github/* ]] || [[ "$file" == */.github/* ]]; then
    echo "Skipping .github file: $file"
    continue
  fi

  # Skip if file does not exist (e.g. deleted in the same commit)
  if [ ! -f "$file" ]; then
    echo "Skipping missing file: $file"
    continue
  fi

  echo "Checking: $file"

  needs_summary=false
  needs_learned=false
  needs_commands=false

  grep -q "^## Summary"        "$file" || needs_summary=true
  grep -q "^## What I Learned" "$file" || needs_learned=true
  grep -q "^## Commands"       "$file" || needs_commands=true

  if $needs_summary || $needs_learned || $needs_commands; then
    tmpfile=$(mktemp) || { echo "  ✗ Failed to create temp file for: $file" >&2; continue; }
    trap 'rm -f "$tmpfile"' EXIT
    $needs_summary  && printf "## Summary\n\n"        >> "$tmpfile"
    $needs_learned  && printf "## What I Learned\n\n" >> "$tmpfile"
    $needs_commands && printf "## Commands\n\n"        >> "$tmpfile"
    cat "$file" >> "$tmpfile"
    mv "$tmpfile" "$file"
    echo "  → Added missing sections to: $file"
  else
    echo "  ✓ All sections present in: $file"
  fi
done
