#!/bin/bash

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

cd Benchmarks
swift run -c release voxel-benchmarks \
    library run results.json \
    --max-size 1024 \
    --library Library.json \
    --cycles 3 \
    --mode replace-all

swift run -c release voxel-benchmarks \
    library render results.json \
    --library Library.json \
    --output .
