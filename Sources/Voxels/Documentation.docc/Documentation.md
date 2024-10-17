# ``Voxels``

A Swift library for storage, manipulation, export, and 3D rendering of Voxel data.

## Overview

The library supports storing and manipulating [voxels](https://en.wikipedia.org/wiki/Voxel), with convenience functions to convert the data stored within a collection of voxels into surfaces by generating 3D meshes.
The general term of art for this process is [isosurface](https://en.wikipedia.org/wiki/Isosurface) extraction, originating from medical image technologies.
The library includes implementations of several renderers:

- simple block mesh, rendering voxels as a cube when they're determined to be opaque. 
- Marching Cubes, which does simple linear smoothing to represent angles.
- Surface Net, which treats voxel data as a signed distance field (SDF), to render smooth surfaces.

The library also includes a converter to generate a collection of voxels from a 2D height map (using the [Heightmap](https://github.com/heckj/Heightmap) library) to a collection of voxels.

## Topics

### Voxel Storage

- ``VoxelHash``
- ``VoxelArray``
- ``VoxelAccessible``
- ``VoxelWritable``

### Voxel Updates

- ``VoxelUpdate``

### Renderers

- ``BlockMeshRenderer``
- ``VoxelBlockRenderable``
- ``MarchingCubesRenderer``
- ``SurfaceNetRenderer``
- ``VoxelSurfaceRenderable``

### Converters

- ``HeightmapConverter``
- ``SDF``
- ``SDFSampleable``
- ``VoxelSampleable``

### Supporting Types

- ``VoxelBounds``
- ``VoxelIndex``
- ``StrideIndexable``
- ``VoxelScale``
- ``MeshBuffer``
- ``Vector``
- ``CompleteVertex``
- ``CUBE_CORNERS``
- ``CubeFace``
- ``SurfaceNetsBuffer``

### Errors

- ``HeightmapError``
- ``VoxelAccessError``

### Sample Data

- ``SampleMeshData``
