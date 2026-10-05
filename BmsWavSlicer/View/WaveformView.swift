import SwiftUI
import AVFoundation
import System

func spanToSamples<T: BinaryFloatingPoint>(_ span: Span<T>) -> [CGFloat] {
    var samples = Array(repeating: CGFloat(0.0), count: span.count)
    for i in 0..<span.count {
        samples[i] = CGFloat(span[i])
    }
    return samples
}

func spanToSamples<T: BinaryInteger>(_ span: Span<T>) -> [CGFloat] {
    var samples = Array(repeating: CGFloat(0.0), count: span.count)
    for i in 0..<span.count {
        samples[i] = CGFloat(span[i])
    }
    return samples
}

func channelDataToSamples(_ buffer: AVReadOnlyAudioPCMBuffer, _ index: Int) -> [CGFloat] {
    switch buffer.channelData(index) {
    case let .float(span): spanToSamples(span)
    case let .int16(span): spanToSamples(span)
    case let .int32(span): spanToSamples(span)
    default: []
    }
}

let xPerSample = 0.002075

func waveformPath(_ size: CGSize, _ samples: AVReadOnlyAudioPCMBuffer) -> Path {
    var path = Path()

    path.move(to: CGPoint(x: 0, y: size.height * 0.5))
    let topChannel: [CGFloat] = channelDataToSamples(samples, 0)
    for i in 0..<topChannel.count {
        let y = (1.0 - topChannel[i]) * 0.5 * size.height
        path.addLine(to: CGPoint(x: Double(i) * xPerSample, y: y))
    }
    path.addLine(to: CGPoint(x: CGFloat(topChannel.count), y: 0.5 * size.height))
    path.closeSubpath()
    
    path.move(to: CGPoint(x: 0, y: size.height * 0.5))
    let bottomChannel: [CGFloat] = channelDataToSamples(samples, 1)
    for i in 0..<bottomChannel.count {
        let y = (1.0 + bottomChannel[i]) * 0.5 * size.height
        path.addLine(to: CGPoint(x: Double(i) * xPerSample, y: y))
    }
    path.addLine(to: CGPoint(x: CGFloat(topChannel.count), y: 0.5 * size.height))
    path.closeSubpath()

    return path
}

struct WaveformView: View {
    var xScale: Double
    @Binding var sliceMarks: [SliceMark]
    var asset: WavAsset
    
    @State private var samples: AVReadOnlyAudioPCMBuffer? = nil

    var body: some View {
        HStack {
            if let samples = samples {
                Canvas { context, size in
                    context.fill(waveformPath(size, samples), with: .foreground)
                }
                .frame(width: Double(samples.frameLength) * xPerSample)
                .scaleEffect(x: xScale, anchor: .topLeading)
            }
        }
        .task {
            if let newSamples = await asset.loadSamples() {
                self.samples = newSamples
            }
        }
    }
}
