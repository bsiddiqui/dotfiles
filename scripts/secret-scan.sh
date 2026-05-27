#!/usr/bin/env bash
set -euo pipefail

pattern='(sk-ant-|sk-proj-|sk-[A-Za-z0-9_-]{32,}|xox[baprs]-|BEGIN (OPENSSH|RSA|EC|DSA) PRIVATE KEY)'

if [ "${1:-}" = "--staged" ]; then
  if git diff --cached --no-ext-diff --unified=0 -- . ':!templates/*' ':!README.md' ':!scripts/secret-scan.sh' |
    grep -E "^\+[^+].*$pattern" >/dev/null 2>&1; then
    echo "Potential secret detected in staged changes. Move it to an ignored local file or secret manager." >&2
    exit 1
  fi
  exit 0
fi

matches="$(git grep -I -l -E "$pattern" -- . ':!templates/*' ':!README.md' ':!scripts/secret-scan.sh' || true)"

if [ -n "$matches" ]; then
  echo "Potential secrets found in tracked files:" >&2
  echo "$matches" >&2
  exit 1
fi
