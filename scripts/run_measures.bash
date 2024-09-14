#!/bin/bash

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

cd Benchmarks

swift package benchmark --target VoxelBenchmark
