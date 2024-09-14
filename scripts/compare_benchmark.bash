#!/bin/bash

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

cd Benchmarks
rm -f devcheck
rm -f diff.html

swift run -c release voxel-benchmarks \
    library run --library Library.json \
    --max-size 1024 \
    --cycles 1 \
    devcheck

swift run -c release voxel-benchmarks \
    results compare \
    results.json devcheck \
    --list-cutoff 1.1

swift run -c release voxel-benchmarks \
    results compare \
    results.json devcheck \
    --output diff.html
