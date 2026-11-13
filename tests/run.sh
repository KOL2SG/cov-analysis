#!/usr/bin/env bash
# tests/run.sh — run every tests/test_*.sh, report pass/fail.

# The tests source cov-analysis, which needs bash >= 4.4. macOS's /bin/bash is
# 3.2: re-run under a newer one when it is installed (Homebrew's), as
# cov-analysis itself does. Plain bash 3.2 syntax up to here.
if [ "${BASH_VERSINFO[0]}" -lt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -lt 4 ]; }; then
  for _b in "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin/bash}" /opt/homebrew/bin/bash /usr/local/bin/bash; do
    [ -n "$_b" ] && [ -x "$_b" ] && exec "$_b" "$0" "$@"
  done
  echo "tests need bash >= 4.4, but this is bash $BASH_VERSION (on macOS: brew install bash)" >&2
  exit 1
fi
set -uo pipefail

cd "$(dirname "$0")/.."

pass=0
fail=0
failed_tests=()

shopt -s nullglob
for t in tests/test_*.sh; do
  echo "─── $t ───"
  if "$BASH" "$t"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    failed_tests+=("$t")
  fi
done

echo
echo "Results: $pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then
  printf 'Failed: %s\n' "${failed_tests[@]}"
  exit 1
fi
