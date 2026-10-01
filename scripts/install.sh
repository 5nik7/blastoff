#!/usr/bin/env bash
set -u
script_dir=${BASH_SOURCE[0]%/*}
[[ $script_dir == "${BASH_SOURCE[0]}" ]] && script_dir=.
root=$(CDPATH='' cd -- "$script_dir/.." && pwd -P) || exit 1
exec "${BLASTOFF_PYTHON:-python3}" -I "$root/scripts/install.py" "$@"
