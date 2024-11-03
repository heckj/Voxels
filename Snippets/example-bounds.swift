import Voxels

let bounds = VoxelBounds(min: (0, 0, 0), max: (2, 2, 2))

print("All indices")
for voxelIndex in bounds {
    print(voxelIndex)
}

//    All indices
//    [0, 0, 0]
//    [0, 0, 1]
//    [0, 0, 2]
//    [0, 1, 0]
//    [0, 1, 1]
//    [0, 1, 2]
//    [0, 2, 0]
//    [0, 2, 1]
//    [0, 2, 2]
//    [1, 0, 0]
//    [1, 0, 1]
//    [1, 0, 2]
//    [1, 1, 0]
//    [1, 1, 1]
//    [1, 1, 2]
//    [1, 2, 0]
//    [1, 2, 1]
//    [1, 2, 2]
//    [2, 0, 0]
//    [2, 0, 1]
//    [2, 0, 2]
//    [2, 1, 0]
//    [2, 1, 1]
//    [2, 1, 2]
//    [2, 2, 0]
//    [2, 2, 1]
//    [2, 2, 2]

print("slice indices")
let slice = bounds.y(0...0)
for voxelIndex in slice {
    print(voxelIndex)
}

//    slice indices
//    [0, 0, 0]
//    [0, 0, 1]
//    [0, 0, 2]
//    [1, 0, 0]
//    [1, 0, 1]
//    [1, 0, 2]
//    [2, 0, 0]
//    [2, 0, 1]
//    [2, 0, 2]
