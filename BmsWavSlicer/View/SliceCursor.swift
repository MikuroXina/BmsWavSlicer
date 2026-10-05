import SwiftUI

func findSectionOn(_ markerMs: Double, _ rulerMarks: [RulerMark]) -> RulerMark {
    var start = 0
    var end = rulerMarks.count
    // the solution is in [start, end)
    while start + 1 < end {
        let mid = start + Int(floor(Double(end - start) / 2.0))
        if Double(rulerMarks[mid].at.rawValue) <= markerMs {
            start = mid
        } else {
            end = mid
        }
    }
    return rulerMarks[start]
}

func findTempoAt(_ markerMs: Double, _ rulerMarks: [RulerMark]) -> Tempo {
    let tempos: [(Double, Tempo)] = rulerMarks.compactMap { mark in
        if case let RulerMark.tempoChange(at, tempo) = mark {
            (Double(at.rawValue), tempo)
        } else {
            nil
        }
    }
    var start = 0
    var end = tempos.count
    // the solution is in [start, end)
    while start + 1 < end {
        let mid = start + Int(floor(Double(end - start) / 2.0))
        if tempos[mid].0 <= markerMs {
            start = mid
        } else {
            end = mid
        }
    }
    return tempos[start].1
}

struct SliceCursor: View {
    var xScale: Double
    var rulerMarks: [RulerMark]
    var quantizeMode: QuantizeMode
    var resolution: TickResolution

    @State private var hoverLocation: CGPoint = .zero
    @State private var isHovering: Bool = false

    static let microSecondPerX = 1e4

    var body: some View {
        Rectangle()
            .fill(.black.opacity(0.0))
            .onContinuousHover() { phase in
                switch phase {
                case let .active(pos):
                    isHovering = true
                    hoverLocation = pos
                case .ended:
                    isHovering = false
                }
            }
            .overlay(alignment: .leading) {
                let markerX = hoverLocation.x
                let markerMs = markerX * Self.microSecondPerX / xScale
                let sectionOn = findSectionOn(markerMs, rulerMarks)
                let sectionX = Double(sectionOn.at.rawValue) * xScale / Self.microSecondPerX

                let tempo = findTempoAt(markerMs, rulerMarks)
                let quantum = quantizeMode.toStride(resolution)
                let strideX = Double(quantum.rawValue) * Double(tempo.rawValue) * xScale / Double(resolution.rawValue) / Self.microSecondPerX
                let snapX = round((markerX - sectionX) / strideX) * strideX + sectionX

                Rectangle()
                    .fill(.red)
                    .frame(width: 1.0, height: 1e6)
                    .offset(x: snapX, y: 0.0)
            }
    }
}
