# RenderExample project

A multiplatform app for exploring and verifying voxel rendering.

## locally on the command line

    export DEVELOPER_DIR=/Applications/Xcode.app
    xcodebuild -scheme RenderExamples test

## CI

The GitHub Actions CI runner is configured to run with Xcode 15.4 on macOS 14
to replicate these results. If a different Xcode version is used, the images
are just _slightly_ differently rendered, and will likely show an error, even
if the result is visually extremely similar.

