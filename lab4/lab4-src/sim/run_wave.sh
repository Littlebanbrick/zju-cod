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

# Same bare-filename convention as run_iverilog.sh; Icarus gets the
# project-relative path through a macro override.
iverilog -g2012 $DEFINE \
    -DROM_FILE="\"$ROM\"" -DRAM_FILE="\"program/D_mem.mem\"" \
    -I src -s wave_tb \
    -o "build/lab4_wave_${1:-base}.out" \
    src/*.v sim/wave_tb.v
vvp "build/lab4_wave_${1:-base}.out"
echo "waveform: sim/wave.vcd"
