# Voxels

A Swift library for storage, manipulation, export, and rendering of Voxel data.

- [API documentation](https://swiftpackageindex.com/heckj/Voxels/documentation/voxels)

## References:

The general term of art for all this is "isosurface extraction"

Fast Surface Nets
- Related code: https://github.com/bonsairobo/fast-surface-nets-rs/
- [Article on Surface Nets](https://bonsairobo.medium.com/smooth-voxel-mapping-a-technical-deep-dive-on-real-time-surface-nets-and-texturing-ef06d0f8ca14)
- [Dual Contouring with Hermite Data research paper](https://www.cse.wustl.edu/~taoju/research/dualContour.pdf)
- [Dual Contouring Tutorial](https://www.boristhebrave.com/2018/04/15/dual-contouring-tutorial/)
  - [associated code examples (python)](https://github.com/BorisTheBrave/mc-dc/tree/master)

Copies of some of these articles and papers reside in [refs](refs/).

## benchmarking notes

1D Benchmarks:

    swift package benchmark --target VoxelBenchmark

2D Benchmarks:

    ./scripts/rebuild_benchmarks.bash
    ./scripts/compare_benchmark.bash
- [benchmark results](https://github.com/heckj/Voxels/blob/main/Benchmarks/Results.md)

## Checking documentation

    swift package generate-documentation --analyze --warnings-as-errors
