import SwiftUI
import AVFoundation

struct TrackList: View {
    @Binding var tracks: [WavAsset]
    var xScale: Double
    @Binding var sliceMarks: [[SliceMark]]
    var rulerMarks: [RulerMark]
    var quantizeMode: QuantizeMode
    var resolution: TickResolution
    
    let rulerHeight = 20.0
    let trackHeight = 100.0
    let trackHeadWidth = 120.0
    let border = Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
    
    var body: some View {
        ScrollView([.vertical]) {
            HStack {
                ScrollView {
                    LazyVGrid(columns: [.init(.fixed(trackHeadWidth))], alignment: .leading) {
                        Spacer().frame(width: trackHeadWidth, height: rulerHeight)
                        ForEach($tracks, editActions: [.move, .delete]) { $track in
                            Divider()
                            Text("\(track.file?.url.lastPathComponent ?? "Unknown")")
                                .font(.caption)
                                .padding()
                                .frame(width: trackHeadWidth, height: trackHeight)
                                .background(border)
                        }
                    }
                }
                .frame(maxWidth: trackHeadWidth, maxHeight: .infinity)
                GeometryReader { geo in
                    ScrollView([.horizontal]) {
                        ZStack {
                            LazyVGrid(columns: [.init(.flexible())], alignment: .leading) {
                                Ruler(xScale: xScale, rulerMarks: rulerMarks)
                                    .frame(width: geo.size.width, height: rulerHeight)
                                ForEach(0..<tracks.count, id: \.description) { i in
                                    WaveformView(xScale: xScale, sliceMarks: $sliceMarks[i], asset: tracks[i])
                                        .frame(width: geo.size.width, height: trackHeight, alignment: .topLeading)
                                        .background(border)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            SliceCursor(xScale: xScale, rulerMarks: rulerMarks, quantizeMode: quantizeMode, resolution: resolution)
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        if tracks.isEmpty {
                            Text("Open Track menu to Add your assets")
                                .font(.headline)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var project = Project()
    TrackList(
        tracks: $project.assets,
        xScale: project.xScale,
        sliceMarks: $project.sliceMarks,
        rulerMarks: project.rulerMarks,
        quantizeMode: project.quantizeMode,
        resolution: project.resolution,
    )
}
