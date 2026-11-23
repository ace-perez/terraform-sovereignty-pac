#!/usr/bin/env bash
# Run every Sentinel test case against the six policies and the HCP bundle.
#
# The brief's folder structure keeps tests in tests/<policy>/ at the repo root,
# but the Sentinel CLI looks for them in test/<policy>/ next to the policies.
# This script stages copies where the CLI expects them (both copies are
# git-ignored), then runs "sentinel test".
set -euo pipefail          # stop on any error, unset variable or failed pipe stage

root="$(cd "$(dirname "$0")/.." && pwd)"

stage() {                  # $1 = directory holding the policies
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
