//
//  RenderExamplesApp.swift
//  RenderExamples
//
//  Created by Joseph Heck on 8/27/24.
//

import SwiftUI
import Voxels

@main
struct RenderExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            // ContentView()
            // QuickCheckView()
            VoxelExplorerView(ObservableVoxelData(SampleMeshData.SDFBrick()))
            // VoxelDataEditorView(data: ObservableVoxelData(SampleMeshData.SDFBrick()))
        }
    }
}
