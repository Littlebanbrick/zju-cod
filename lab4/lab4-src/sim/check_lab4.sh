#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
for test in base more int; do
    ./sim/run_iverilog.sh "$test"
done
