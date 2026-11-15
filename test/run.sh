#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1
output=$(soma run test/main.soma)
printf '%s\n' "$output"
printf '%s\n' "$output" | grep -q '^PASS Owl matrix product and Soma XOR training$'
