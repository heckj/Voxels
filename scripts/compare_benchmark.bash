#!/bin/bash

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

rm -f devcheck
rm -f diff.html

swift run -c release voxel-benchmarks \
    library run --library Benchmarks/Library.json \
    --cycles 2 \
    devcheck

swift run -c release voxel-benchmarks \
    results compare \
    Benchmarks/results.json devcheck \
    --list-cutoff 1.1

swift run -c release voxel-benchmarks \
    results compare \
    Benchmarks/results.json devcheck \
    --output diff.html
