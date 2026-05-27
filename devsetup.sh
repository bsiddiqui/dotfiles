#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "devsetup.sh is kept for muscle memory. Running bootstrap.sh instead."
exec "$script_dir/bootstrap.sh" "$@"
