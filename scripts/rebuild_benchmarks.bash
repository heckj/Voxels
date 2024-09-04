#!/bin/bash

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

echo "expect 7 to 8 seconds a cycle"

swift run -c release voxel-benchmarks \
    library run Benchmarks/results.json \
    --library Benchmarks/Library.json \
    --cycles 2 \
    --mode replace-all

swift run -c release voxel-benchmarks \
    library render Benchmarks/results.json \
    --library Benchmarks/Library.json \
    --output Benchmarks
