import SwiftUI
import Playgrounds

struct RootView: View {
    @Bindable var project: Project
    
    var body: some View {
        VStack(alignment: .leading, ) {
            Ribbon(xScale: $project.xScale, quantizeMode: $project.quantizeMode)
            TrackList(
                tracks: $project.assets,
                xScale: project.xScale,
                sliceMarks: $project.sliceMarks,
                rulerMarks: project.rulerMarks,
                quantizeMode: project.quantizeMode,
                resolution: project.resolution,
            )
        }
        .focusedSceneValue(project)
    }
}

#Preview {
    RootView(project: Project())
}
