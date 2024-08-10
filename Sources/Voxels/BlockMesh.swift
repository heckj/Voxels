// https://github.com/bonsairobo/block-mesh-rs/blob/main/src/simple.rs
//
//use crate::{
//    bounds::assert_in_bounds, IdentityVoxel, OrientedBlockFace, UnitQuadBuffer, UnorientedUnitQuad, Voxel, VoxelVisibility,
//};
//
//use ilattice::glam::UVec3;
//use ilattice::prelude::Extent;
//use ndshape::Shape;
//
//
///// A fast and simple meshing algorithm that produces a single quad for every visible face of a block.
/////
///// This is faster than [`greedy_quads`](crate::greedy_quads) but it produces many more quads.
//pub fn visible_block_faces<T, S>(
//    voxels: &[T],
//    voxels_shape: &S,
//    min: [u32; 3],
//    max: [u32; 3],
//    faces: &[OrientedBlockFace; 6],
//    output: &mut UnitQuadBuffer,
//) where
//    T: Voxel,
//    S: Shape<3, Coord = u32>,
//{
//    visible_block_faces_with_voxel_view::<_, IdentityVoxel<T>, _>(
//        voxels,
//        voxels_shape,
//        min,
//        max,
//        faces,
//        output,
//    )
//}
//
///// Same as [`visible_block_faces`](visible_block_faces),
///// with the additional ability to interpret the array as some other type.
///// Use this if you want to mesh the same array multiple times
///// with different sets of voxels being visible.
//pub fn visible_block_faces_with_voxel_view<'a, T, V, S>(
//    voxels: &'a [T],
//    voxels_shape: &S,
//    min: [u32; 3],
//    max: [u32; 3],
//    faces: &[OrientedBlockFace; 6],
//    output: &mut UnitQuadBuffer,
//) where
//    V: Voxel + From<&'a T>,
//    S: Shape<3, Coord = u32>,
//{
//    assert_in_bounds(voxels, voxels_shape, min, max);
//
//    let min = UVec3::from(min).as_ivec3();
//    let max = UVec3::from(max).as_ivec3();
//    let extent = Extent::from_min_and_max(min, max);
//    let interior = extent.padded(-1); // Avoid accessing out of bounds with a 3x3x3 kernel.
//    let interior =
//        Extent::from_min_and_shape(interior.minimum.as_uvec3(), interior.shape.as_uvec3());
//
//    let kernel_strides =
//        faces.map(|face| voxels_shape.linearize(face.signed_normal().as_uvec3().to_array()));
//
//    for p in interior.iter3() {
//        let p_array = p.to_array();
//        let p_index = voxels_shape.linearize(p_array);
//        let p_voxel = V::from(unsafe { voxels.get_unchecked(p_index as usize) });
//
//        if let VoxelVisibility::Empty = p_voxel.get_visibility() {
//            continue;
//        }
//
//        for (face_index, face_stride) in kernel_strides.into_iter().enumerate() {
//            let neighbor_index = p_index.wrapping_add(face_stride);
//            let neighbor_voxel = V::from(unsafe { voxels.get_unchecked(neighbor_index as usize) });
//
//            // TODO: If the face lies between two transparent voxels, we choose not to mesh it. We might need to extend the
//            // IsOpaque trait with different levels of transparency to support this.
//            let face_needs_mesh = match neighbor_voxel.get_visibility() {
//                VoxelVisibility::Empty => true,
//                VoxelVisibility::Translucent => p_voxel.get_visibility() == VoxelVisibility::Opaque,
//                VoxelVisibility::Opaque => false,
//            };
//
//            if face_needs_mesh {
//                output.groups[face_index].push(UnorientedUnitQuad { minimum: p_array });
//            }
//        }
//    }
//}
//
//#[cfg(test)]
//mod tests {
//    use super::*;
//    use crate::RIGHT_HANDED_Y_UP_CONFIG;
//    use ndshape::{ConstShape, ConstShape3u32};
//
//    #[test]
//    #[should_panic]
//    fn panics_with_max_out_of_bounds_access() {
//        let samples = [EMPTY; SampleShape::SIZE as usize];
//        let mut buffer = UnitQuadBuffer::new();
//        visible_block_faces(
//            &samples,
//            &SampleShape {},
//            [0; 3],
//            [34, 33, 33],
//            &RIGHT_HANDED_Y_UP_CONFIG.faces,
//            &mut buffer,
//        );
//    }
//
//    #[test]
//    #[should_panic]
//    fn panics_with_min_out_of_bounds_access() {
//        let samples = [EMPTY; SampleShape::SIZE as usize];
//        let mut buffer = UnitQuadBuffer::new();
//        visible_block_faces(
//            &samples,
//            &SampleShape {},
//            [0, 34, 0],
//            [33; 3],
//            &RIGHT_HANDED_Y_UP_CONFIG.faces,
//            &mut buffer,
//        );
//    }
//
//    type SampleShape = ConstShape3u32<34, 34, 34>;
//
//    /// Basic voxel type with one byte of texture layers
//    #[derive(Default, Clone, Copy, Eq, PartialEq)]
//    struct BoolVoxel(bool);
//
//    const EMPTY: BoolVoxel = BoolVoxel(false);
//
//    impl Voxel for BoolVoxel {
//        fn get_visibility(&self) -> VoxelVisibility {
//            if *self == EMPTY {
//                VoxelVisibility::Empty
//            } else {
//                VoxelVisibility::Opaque
//            }
//        }
//    }
//
//}


//  https://github.com/bonsairobo/block-mesh-rs/blob/main/src/lib.rs
//
//! [![Crates.io](https://img.shields.io/crates/v/block-mesh.svg)](https://crates.io/crates/block-mesh)
//! [![Docs.rs](https://docs.rs/block-mesh/badge.svg)](https://docs.rs/block-mesh)
//!
//! Fast algorithms for generating voxel block meshes.
//!
//! ![Mesh Examples](https://raw.githubusercontent.com/bonsairobo/block-mesh-rs/main/examples-crate/render/mesh_examples.png)
//!
//! Two algorithms are included:
//! - [`visible_block_faces`](crate::visible_block_faces): very fast but suboptimal meshes
//! - [`greedy_quads`](crate::greedy_quads): not quite as fast, but far fewer triangles are generated
//!
//! Benchmarks show that [`visible_block_faces`](crate::visible_block_faces) generates about 40 million quads per second on a
//! single core of a 2.5 GHz Intel Core i7. Assuming spherical input data, [`greedy_quads`](crate::greedy_quads) can generate a
//! more optimal version of the same mesh with 1/3 of the quads, but it takes about 3 times longer. To run the benchmarks
//! yourself, `cd bench/ && cargo bench`.
//!
//! # Example Code
//!
//! ```
//! use block_mesh::ndshape::{ConstShape, ConstShape3u32};
//! use block_mesh::{greedy_quads, GreedyQuadsBuffer, MergeVoxel, Voxel, VoxelVisibility, RIGHT_HANDED_Y_UP_CONFIG};
//!
//! #[derive(Clone, Copy, Eq, PartialEq)]
//! struct BoolVoxel(bool);
//!
//! const EMPTY: BoolVoxel = BoolVoxel(false);
//! const FULL: BoolVoxel = BoolVoxel(true);
//!
//! impl Voxel for BoolVoxel {
//!     fn get_visibility(&self) -> VoxelVisibility {
//!         if *self == EMPTY {
//!             VoxelVisibility::Empty
//!         } else {
//!             VoxelVisibility::Opaque
//!         }
//!     }
//! }
//!
//! impl MergeVoxel for BoolVoxel {
//!     type MergeValue = Self;
//!     type MergeValueFacingNeighbour = Self;
//!
//!     fn merge_value(&self) -> Self::MergeValue {
//!         *self
//!     }
//!
//!     fn merge_value_facing_neighbour(&self) -> Self::MergeValueFacingNeighbour {
//!         *self
//!     }
//! }
//!
//! // A 16^3 chunk with 1-voxel boundary padding.
//! type ChunkShape = ConstShape3u32<18, 18, 18>;
//!
//! // This chunk will cover just a single octant of a sphere SDF (radius 15).
//! let mut voxels = [EMPTY; ChunkShape::SIZE as usize];
//! for i in 0..ChunkShape::SIZE {
//!     let [x, y, z] = ChunkShape::delinearize(i);
//!     voxels[i as usize] = if ((x * x + y * y + z * z) as f32).sqrt() < 15.0 {
//!         FULL
//!     } else {
//!         EMPTY
//!     };
//! }
//!
//! let mut buffer = GreedyQuadsBuffer::new(voxels.len());
//! greedy_quads(
//!     &voxels,
//!     &ChunkShape {},
//!     [0; 3],
//!     [17; 3],
//!     &RIGHT_HANDED_Y_UP_CONFIG.faces,
//!     &mut buffer
//! );
//!
//! // Some quads were generated.
//! assert!(buffer.quads.num_quads() > 0);
//! ```

mod bounds;
mod buffer;
pub mod geometry;
mod greedy;
mod simple;

pub use buffer::*;
#[doc(inline)]
pub use geometry::*;
pub use greedy::*;
pub use simple::*;

pub use ilattice;
pub use ndshape;

/// Describes how this voxel influences mesh generation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VoxelVisibility {
    /// This voxel should not produce any geometry.
    Empty,
    /// Should produce geometry, and also light can pass through.
    Translucent,
    /// Light cannot pass through this voxel.
    Opaque,
}

/// Implement on your voxel types to inform the library
/// how to generate geometry for this voxel.
pub trait Voxel {
    fn get_visibility(&self) -> VoxelVisibility;
}

/// Used as a dummy for functions that must wrap a voxel
/// but don't want to change the original's properties.
struct IdentityVoxel<'a, T: Voxel>(&'a T);

impl<'a, T: Voxel> Voxel for IdentityVoxel<'a, T> {
    #[inline]
    fn get_visibility(&self) -> VoxelVisibility {
        self.0.get_visibility()
    }
}

impl<'a, T: Voxel> From<&'a T> for IdentityVoxel<'a, T> {
    fn from(voxel: &'a T) -> Self {
        Self(voxel)
    }
}
