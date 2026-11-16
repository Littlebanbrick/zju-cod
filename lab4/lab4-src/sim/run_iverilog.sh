#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p build

case "${1:-base}" in
    base) DEFINE="-DTEST_BASE"; ROM="program/I_mem_4.mem" ;;
    more) DEFINE="-DTEST_MORE"; ROM="program/I_mem_more.mem" ;;
    int)  DEFINE="-DTEST_INT";  ROM="program/I_mem_INT.mem" ;;
    *)
        echo "usage: $0 [base|more|int]" >&2
        exit 2
        ;;
esac

# The RTL uses bare filenames so that Vivado can find them in its run
# directory. For Icarus, keep the .mem files in lab4/program and inject the
# relative path here; no symlink or copy is needed.
iverilog -g2012 $DEFINE \
    -DROM_FILE="\"$ROM\"" -DRAM_FILE="\"program/D_mem.mem\"" \
    -I src -s socTest_tb \
    -o "build/lab4_${1:-base}.out" \
    src/*.v sim/socTest_tb.v
vvp "build/lab4_${1:-base}.out"
