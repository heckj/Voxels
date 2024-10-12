# Benchmarks for Voxel processing

To run all the available benchmarks:

    swift package benchmark --format markdown

For more help on the package-benchmark SwiftPM plugin:

    swift package benchmark help

Creating a local baseline:

    swift package --allow-writing-to-package-directory benchmark baseline update dev
    swift package benchmark baseline list

Comparing to a the baseline 'alpha'

    swift package benchmark baseline compare 0.1.0

For more details on creating and comparing baselines, read [Creating and Comparing Benchmark Baselines](https://swiftpackageindex.com/ordo-one/package-benchmark/main/documentation/benchmark/creatingandcomparingbaselines).

## baseline per tag:

`swift package --allow-writing-to-package-directory benchmark baseline update 0.1.0`
`swift package benchmark --grouping metric --format markdown > 0.1.0.md`

