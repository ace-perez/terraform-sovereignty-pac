#!/usr/bin/env bash
# Run every Sentinel test against the six policies and the HCP bundle.
# The CLI expects tests in test/<policy>/ next to the policies, so copies are
# staged there from tests/ (git-ignored) before running "sentinel test".
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

stage() { # $1 = folder holding the policies
  local dir="$1"
  rm -rf "$dir/test" "$dir/testdata"
  mkdir -p "$dir/test"
  cp -r "$root/tests/testdata" "$dir/testdata"
  for policy in "$dir"/*.sentinel; do
    name="$(basename "$policy" .sentinel)"
    if [ -d "$root/tests/$name" ]; then
      cp -r "$root/tests/$name" "$dir/test/$name"
    fi
  done
}

echo "== Modular policies =="
stage "$root/sentinel"
(cd "$root/sentinel" && sentinel test -verbose)

echo "== HCP Free bundle =="
stage "$root/sentinel/hcp"
(cd "$root/sentinel/hcp" && sentinel test -verbose)
