# ``Voxels``

A Swift library for storage, manipulation, export, and 3D rendering of Voxel data.

## Overview

The general term of art for all this is "[isosurface](https://en.wikipedia.org/wiki/Isosurface) extraction", originating from medical image technologies.
This library hosts data structures for storing and filtering collections of voxels, and includes multiple different means of rendering the results of a collection of voxels to a 3D mesh.
The library includes implementations of several renderers:

- simple block mesh, rendering voxels as a cube when they're determined to be opaque. 
- Marching Cubes, which does simple linear smoothing to represent angles.
- Surface Net, which treats voxel data as a signed distance field (SDF), to render smooth surfaces.

The library also includes a converter to generate a collection of voxels from a 2D height map (using the [Heightmap](https://github.com/heckj/Heightmap) library) to a collection of voxels.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
