//
//  RenderExamplesApp.swift
//  RenderExamples
//
//  Created by Joseph Heck on 8/27/24.
//

import Heightmap
import SwiftUI
import Voxels

@main
struct RenderExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            // ContentView()
            QuickCheckView()
            // VoxelExplorerView(ObservableVoxelData(SampleMeshData.SDFBrick()))
//             VoxelExplorerView(
//                ObservableVoxelData(
//                    HeightmapConverter.heightmap(Heightmap(width: 20, height: 20, seed: 3416717),
//                                                 maxVoxelIndex: 5,
//                                                 voxelSize: 1.0)
//                )
//             )
            // VoxelExplorerView(ObservableVoxelData(SampleMeshData.SDFSphereQuadrant()))
            // VoxelDataEditorView(data: ObservableVoxelData(SampleMeshData.SDFBrick()))
        }
    }
}
