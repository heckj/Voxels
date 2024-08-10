// https://github.com/bonsairobo/block-mesh-rs/blob/main/src/greedy.rs
// mod merge_strategy;
//
// pub use merge_strategy::*;
//
// use crate::{bounds::assert_in_bounds, OrientedBlockFace, QuadBuffer, UnorientedQuad, Voxel, VoxelVisibility};
//
// use ilattice::glam::UVec3;
// use ilattice::prelude::Extent;
// use ndcopy::fill3;
// use ndshape::Shape;
//
// pub trait MergeVoxel: Voxel {
//    type MergeValue: Eq;
//    type MergeValueFacingNeighbour: Eq;
//
//    /// The value used to determine if this voxel can join a given quad in the mesh. This value will be constant for all voxels
//    /// in the same quad. Often this is some material identifier so that the same texture can be used for a full quad.
//    fn merge_value(&self) -> Self::MergeValue;
//
//    fn merge_value_facing_neighbour(&self) -> Self::MergeValueFacingNeighbour;
// }
//
///// Contains the output from the [`greedy_quads`] algorithm. The quads can be used to generate a mesh. See the methods on
///// [`OrientedBlockFace`] and [`UnorientedQuad`] for details.
/////
///// This buffer can be reused between multiple calls of [`greedy_quads`] in order to avoid reallocations.
// pub struct GreedyQuadsBuffer {
//    pub quads: QuadBuffer,
//
//    // A single array is used for the visited mask because it allows us to index by the same strides as the voxels array. It
//    // also only requires a single allocation.
//    visited: Vec<bool>,
// }
//
// impl GreedyQuadsBuffer {
//    pub fn new(size: usize) -> Self {
//        Self {
//            quads: QuadBuffer::new(),
//            visited: vec![false; size],
//        }
//    }
//
//    pub fn reset(&mut self, size: usize) {
//        self.quads.reset();
//
//        if size != self.visited.len() {
//            self.visited = vec![false; size];
//        }
//    }
// }
//
///// The "Greedy Meshing" algorithm described by Mikola Lysenko in the [0fps
///// article](https://0fps.net/2012/06/30/meshing-in-a-minecraft-game/).
/////
///// All visible faces of voxels on the interior of `[min, max]` will be part of some [`UnorientedQuad`] returned via the
///// `output` buffer. A 3x3x3 kernel will be applied to each point on the interior, hence the extra padding required on the
///// boundary. `voxels` only needs to contain the set of points in `[min, max]`.
/////
///// All quads created will have the same "merge value" as defined by the [`MergeVoxel`] trait. The quads can be post-processed
///// into meshes as the user sees fit.
// pub fn greedy_quads<T, S>(
//    voxels: &[T],
//    voxels_shape: &S,
//    min: [u32; 3],
//    max: [u32; 3],
//    faces: &[OrientedBlockFace; 6],
//    output: &mut GreedyQuadsBuffer,
// ) where
//    T: MergeVoxel,
//    S: Shape<3, Coord = u32>,
// {
//    greedy_quads_with_merge_strategy::<_, _, VoxelMerger<T>>(
//        voxels,
//        voxels_shape,
//        min,
//        max,
//        faces,
//        output,
//    )
// }
//
///// Run the greedy meshing algorithm with a custom quad merging strategy using the [`MergeStrategy`] trait.
// pub fn greedy_quads_with_merge_strategy<T, S, Merger>(
//    voxels: &[T],
//    voxels_shape: &S,
//    min: [u32; 3],
//    max: [u32; 3],
//    faces: &[OrientedBlockFace; 6],
//    output: &mut GreedyQuadsBuffer,
// ) where
//    T: Voxel,
//    S: Shape<3, Coord = u32>,
//    Merger: MergeStrategy<Voxel = T>,
// {
//    assert_in_bounds(voxels, voxels_shape, min, max);
//
//    let min = UVec3::from(min).as_ivec3();
//    let max = UVec3::from(max).as_ivec3();
//    let extent = Extent::from_min_and_max(min, max);
//
//    output.reset(voxels.len());
//    let GreedyQuadsBuffer {
//        visited,
//        quads: QuadBuffer { groups },
//    } = output;
//
//    let interior = extent.padded(-1); // Avoid accessing out of bounds with a 3x3x3 kernel.
//    let interior =
//        Extent::from_min_and_shape(interior.minimum.as_uvec3(), interior.shape.as_uvec3());
//
//    for (group, face) in groups.iter_mut().zip(faces.iter()) {
//        greedy_quads_for_face::<_, _, Merger>(voxels, voxels_shape, interior, face, visited, group);
//    }
// }
//
// fn greedy_quads_for_face<T, S, Merger>(
//    voxels: &[T],
//    voxels_shape: &S,
//    interior: Extent<UVec3>,
//    face: &OrientedBlockFace,
//    visited: &mut [bool],
//    quads: &mut Vec<UnorientedQuad>,
// ) where
//    T: Voxel,
//    S: Shape<3, Coord = u32>,
//    Merger: MergeStrategy<Voxel = T>,
// {
//    visited.fill(false);
//
//    let OrientedBlockFace {
//        n_sign,
//        permutation,
//        n,
//        u,
//        v,
//        ..
//    } = face;
//
//    let [n_axis, u_axis, v_axis] = permutation.axes();
//    let i_n = n_axis.index();
//    let i_u = u_axis.index();
//    let i_v = v_axis.index();
//
//    let interior_shape = interior.shape.to_array();
//    let num_slices = interior_shape[i_n];
//    let mut slice_shape = [0; 3];
//    slice_shape[i_n] = 1;
//    slice_shape[i_u] = interior_shape[i_u];
//    slice_shape[i_v] = interior_shape[i_v];
//    let mut slice_extent = Extent::from_min_and_shape(interior.minimum, UVec3::from(slice_shape));
//
//    let n_stride = voxels_shape.linearize(n.to_array());
//    let u_stride = voxels_shape.linearize(u.to_array());
//    let v_stride = voxels_shape.linearize(v.to_array());
//    let face_strides = FaceStrides {
//        n_stride,
//        u_stride,
//        v_stride,
//        // The offset to the voxel sharing this cube face.
//        visibility_offset: if *n_sign > 0 {
//            n_stride
//        } else {
//            0u32.wrapping_sub(n_stride)
//        },
//    };
//
//    for _ in 0..num_slices {
//        let slice_ub = slice_extent.least_upper_bound().to_array();
//        let u_ub = slice_ub[i_u];
//        let v_ub = slice_ub[i_v];
//
//        for quad_min in slice_extent.iter3() {
//            let quad_min_array = quad_min.to_array();
//            let quad_min_index = voxels_shape.linearize(quad_min_array);
//            let quad_min_voxel = unsafe { voxels.get_unchecked(quad_min_index as usize) };
//            if unsafe {
//                !face_needs_mesh(
//                    quad_min_voxel,
//                    quad_min_index,
//                    face_strides.visibility_offset,
//                    voxels,
//                    visited,
//                )
//            } {
//                continue;
//            }
//            // We have at least one face that needs a mesh. We'll try to expand that face into the biggest quad we can find.
//
//            // These are the boundaries on quad width and height so it is contained in the slice.
//            let max_width = u_ub - quad_min_array[i_u];
//            let max_height = v_ub - quad_min_array[i_v];
//
//            let (quad_width, quad_height) = unsafe {
//                Merger::find_quad(
//                    quad_min_index,
//                    max_width,
//                    max_height,
//                    &face_strides,
//                    voxels,
//                    visited,
//                )
//            };
//            debug_assert!(quad_width >= 1);
//            debug_assert!(quad_width <= max_width);
//            debug_assert!(quad_height >= 1);
//            debug_assert!(quad_height <= max_height);
//
//            // Mark the quad as visited.
//            let mut quad_shape = [0; 3];
//            quad_shape[i_n] = 1;
//            quad_shape[i_u] = quad_width;
//            quad_shape[i_v] = quad_height;
//            fill3(quad_shape, true, visited, voxels_shape, quad_min_array);
//
//            quads.push(UnorientedQuad {
//                minimum: quad_min.to_array(),
//                width: quad_width,
//                height: quad_height,
//            });
//        }
//
//        // Move to the next slice.
//        slice_extent = slice_extent + *n;
//    }
// }
//
///// Returns true iff the given `voxel` face needs to be meshed. This means that we haven't already meshed it, it is non-empty,
///// and it's visible (not completely occluded by an adjacent voxel).
// pub(crate) unsafe fn face_needs_mesh<T>(
//    voxel: &T,
//    voxel_stride: u32,
//    visibility_offset: u32,
//    voxels: &[T],
//    visited: &[bool],
// ) -> bool
// where
//    T: Voxel,
// {
//    if voxel.get_visibility() == VoxelVisibility::Empty || visited[voxel_stride as usize] {
//        return false;
//    }
//
//    let adjacent_voxel =
//        voxels.get_unchecked(voxel_stride.wrapping_add(visibility_offset) as usize);
//
//    // TODO: If the face lies between two transparent voxels, we choose not to mesh it. We might need to extend the IsOpaque
//    // trait with different levels of transparency to support this.
//    match adjacent_voxel.get_visibility() {
//        VoxelVisibility::Empty => true,
//        VoxelVisibility::Translucent => voxel.get_visibility() == VoxelVisibility::Opaque,
//        VoxelVisibility::Opaque => false,
//    }
// }
//
// #[cfg(test)]
// mod tests {
//    use super::*;
//    use crate::RIGHT_HANDED_Y_UP_CONFIG;
//    use ndshape::{ConstShape, ConstShape3u32};
//
//    #[test]
//    #[should_panic]
//    fn panics_with_max_out_of_bounds_access() {
//        let samples = [EMPTY; SampleShape::SIZE as usize];
//        let mut buffer = GreedyQuadsBuffer::new(samples.len());
//        greedy_quads(
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
//        let mut buffer = GreedyQuadsBuffer::new(samples.len());
//        greedy_quads(
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
//    impl MergeVoxel for BoolVoxel {
//        type MergeValue = Self;
//        type MergeValueFacingNeighbour = bool;
//
//        fn merge_value(&self) -> Self::MergeValue {
//            *self
//        }
//
//        fn merge_value_facing_neighbour(&self) -> Self::MergeValueFacingNeighbour {
//            true
//        }
//    }
// }

// JavaScript greedyMesh algorithm
// https://github.com/mikolalysenko/mikolalysenko.github.com/blob/gh-pages/MinecraftMeshes/js/greedy.js
//
// function GreedyMesh(volume, dims) {
//  function f(i,j,k) {
//    return volume[i + dims[0] * (j + dims[1] * k)];
//  }
//  //Sweep over 3-axes
//  var quads = [];
//  for(var d=0; d<3; ++d) {
//    var i, j, k, l, w, h
//      , u = (d+1)%3
//      , v = (d+2)%3
//      , x = [0,0,0]
//      , q = [0,0,0]
//      , mask = new Int32Array(dims[u] * dims[v]);
//    q[d] = 1;
//    for(x[d]=-1; x[d]<dims[d]; ) {
//      //Compute mask
//      var n = 0;
//      for(x[v]=0; x[v]<dims[v]; ++x[v])
//      for(x[u]=0; x[u]<dims[u]; ++x[u]) {
//        mask[n++] =
//          (0    <= x[d]      ? f(x[0],      x[1],      x[2])      : false) !=
//          (x[d] <  dims[d]-1 ? f(x[0]+q[0], x[1]+q[1], x[2]+q[2]) : false);
//      }
//      //Increment x[d]
//      ++x[d];
//      //Generate mesh for mask using lexicographic ordering
//      n = 0;
//      for(j=0; j<dims[v]; ++j)
//      for(i=0; i<dims[u]; ) {
//        if(mask[n]) {
//          //Compute width
//          for(w=1; mask[n+w] && i+w<dims[u]; ++w) {
//          }
//          //Compute height (this is slightly awkward
//          var done = false;
//          for(h=1; j+h<dims[v]; ++h) {
//            for(k=0; k<w; ++k) {
//              if(!mask[n+k+h*dims[u]]) {
//                done = true;
//                break;
//              }
//            }
//            if(done) {
//              break;
//            }
//          }
//          //Add quad
//          x[u] = i;  x[v] = j;
//          var du = [0,0,0]; du[u] = w;
//          var dv = [0,0,0]; dv[v] = h;
//          quads.push([
//              [x[0],             x[1],             x[2]            ]
//            , [x[0]+du[0],       x[1]+du[1],       x[2]+du[2]      ]
//            , [x[0]+du[0]+dv[0], x[1]+du[1]+dv[1], x[2]+du[2]+dv[2]]
//            , [x[0]      +dv[0], x[1]      +dv[1], x[2]      +dv[2]]
//          ]);
//          //Zero-out mask
//          for(l=0; l<h; ++l)
//          for(k=0; k<w; ++k) {
//            mask[n+k+l*dims[u]] = false;
//          }
//          //Increment counters and continue
//          i += w; n += w;
//        } else {
//          ++i;    ++n;
//        }
//      }
//    }
//  }
//  return quads;
// }

// https://github.com/bonsairobo/block-mesh-rs/blob/main/src/greedy/merge_strategy.rs
// use crate::greedy::face_needs_mesh;
// use crate::Voxel;
//
// use super::MergeVoxel;
//
//// TODO: implement a MergeStrategy for voxels with an ambient occlusion value at each vertex
//
///// A strategy for merging cube faces into quads.
// pub trait MergeStrategy {
//    type Voxel;
//
//    /// Return the width and height of the quad that should be constructed.
//    ///
//    /// `min_index`: The linear index for the minimum voxel in this quad.
//    ///
//    /// `max_width`: The maximum possible width for the quad to be constructed.
//    ///
//    /// `max_height`: The maximum possible height for the quad to be constructed.
//    ///
//    /// `face_strides`: Strides to help with indexing in the necessary directions for this cube face.
//    ///
//    /// `voxels`: The entire array of voxel data.
//    ///
//    /// `visited`: The bitmask of which voxels have already been meshed. A quad's extent will be marked as visited (`true`)
//    ///            after `find_quad` returns.
//    ///
//    /// # Safety
//    ///
//    /// Some implementations may use unchecked indexing of `voxels` for performance. If this trait is not invoked with correct
//    /// arguments, access out of bounds may cause undefined behavior.
//    unsafe fn find_quad(
//        min_index: u32,
//        max_width: u32,
//        max_height: u32,
//        face_strides: &FaceStrides,
//        voxels: &[Self::Voxel],
//        visited: &[bool],
//    ) -> (u32, u32)
//    where
//        Self::Voxel: Voxel;
// }
//
// pub struct FaceStrides {
//    pub n_stride: u32,
//    pub u_stride: u32,
//    pub v_stride: u32,
//    pub visibility_offset: u32,
// }
//
// pub struct VoxelMerger<T> {
//    marker: std::marker::PhantomData<T>,
// }
//
// impl<T> MergeStrategy for VoxelMerger<T>
// where
//    T: MergeVoxel,
// {
//    type Voxel = T;
//
//    unsafe fn find_quad(
//        min_index: u32,
//        max_width: u32,
//        max_height: u32,
//        face_strides: &FaceStrides,
//        voxels: &[T],
//        visited: &[bool],
//    ) -> (u32, u32) {
//        // Greedily search for the biggest visible quad where all merge values are the same.
//        let quad_value = voxels.get_unchecked(min_index as usize).merge_value();
//        let quad_neighbour_value = voxels
//            .get_unchecked(min_index.wrapping_add(face_strides.visibility_offset) as usize)
//            .merge_value_facing_neighbour();
//
//        // Start by finding the widest quad in the U direction.
//        let mut row_start_stride = min_index;
//        let quad_width = Self::get_row_width(
//            voxels,
//            visited,
//            &quad_value,
//            &quad_neighbour_value,
//            face_strides.visibility_offset,
//            row_start_stride,
//            face_strides.u_stride,
//            max_width,
//        );
//
//        // Now see how tall we can make the quad in the V direction without changing the width.
//        row_start_stride += face_strides.v_stride;
//        let mut quad_height = 1;
//        while quad_height < max_height {
//            let row_width = Self::get_row_width(
//                voxels,
//                visited,
//                &quad_value,
//                &quad_neighbour_value,
//                face_strides.visibility_offset,
//                row_start_stride,
//                face_strides.u_stride,
//                quad_width,
//            );
//            if row_width < quad_width {
//                break;
//            }
//            quad_height += 1;
//            row_start_stride = row_start_stride.wrapping_add(face_strides.v_stride);
//        }
//
//        (quad_width, quad_height)
//    }
// }
//
// impl<T> VoxelMerger<T> {
//    unsafe fn get_row_width(
//        voxels: &[T],
//        visited: &[bool],
//        quad_merge_voxel_value: &T::MergeValue,
//        quad_merge_voxel_value_facing_neighbour: &T::MergeValueFacingNeighbour,
//        visibility_offset: u32,
//        start_stride: u32,
//        delta_stride: u32,
//        max_width: u32,
//    ) -> u32
//    where
//        T: MergeVoxel,
//    {
//        let mut quad_width = 0;
//        let mut row_stride = start_stride;
//        while quad_width < max_width {
//            let voxel = voxels.get_unchecked(row_stride as usize);
//            let neighbour =
//                voxels.get_unchecked(row_stride.wrapping_add(visibility_offset) as usize);
//
//            if !face_needs_mesh(voxel, row_stride, visibility_offset, voxels, visited) {
//                break;
//            }
//
//            if !voxel.merge_value().eq(quad_merge_voxel_value)
//                || !neighbour
//                    .merge_value_facing_neighbour()
//                    .eq(quad_merge_voxel_value_facing_neighbour)
//            {
//                // Voxel needs to be non-empty and match the quad merge value.
//                break;
//            }
//
//            quad_width += 1;
//            row_stride += delta_stride;
//        }
//
//        quad_width
//    }
// }
