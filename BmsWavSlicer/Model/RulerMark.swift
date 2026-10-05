import Foundation
import SwiftMIDIFile

enum RulerMark: Codable {
    case sectionLine(at: MicroSecond)
    case beatLine(at: MicroSecond)
    case tempoChange(at: MicroSecond, tempo: Tempo)

    var at: MicroSecond {
        switch self {
        case let .sectionLine(at): at
        case let .beatLine(at): at
        case let .tempoChange(at, _): at
        }
    }
}

let defaultRulerMarks: [RulerMark] = [
    .tempoChange(at: MicroSecond(rawValue: 0), tempo: Tempo(rawValue: 500_000)),
] + Array(0..<10).map { i in
    i % 4 == 0 ? .sectionLine(at: MicroSecond(rawValue: i * 500 * 1000)) : .beatLine(at: MicroSecond(rawValue: i * 500 * 1000))
}

func rulerMarksFromMidiEvents(resolution: TickResolution, events: [MIDI1File<MusicalMIDIFileTimebase>.Track.Event]) -> [RulerMark] {
    // micro-seconds per quarter beat
    var tempo: UInt32 = 50000
    // quarter beats per section
    var sectionLen: UInt32 = 4
    var currentMs: UInt32 = 0
    var ret: [RulerMark] = []
    for event in events {
        let deltaMs = tempo * event.delta.ticks(using: MusicalMIDIFileTimebase(ticksPerQuarterNote: resolution.rawValue))
        for i in 0..<UInt32((Double(deltaMs) / Double(tempo)).rounded(.up)) {
            let offset = i * tempo
            if i % sectionLen == 0 {
                ret.append(.sectionLine(at: MicroSecond(rawValue: currentMs + offset)))
            } else {
                ret.append(.beatLine(at: MicroSecond(rawValue: currentMs + offset)))
            }
        }
        currentMs += deltaMs
        switch event.event {
        case let .tempo(tempoEvent):
            tempo = tempoEvent.microsecondsPerQuarter
            ret.append(.tempoChange(at: MicroSecond(rawValue: currentMs), tempo: Tempo(rawValue: tempo)))
        case let .timeSignature(timeSignatureEvent):
            sectionLen = 4 * UInt32(timeSignatureEvent.numerator) / UInt32(timeSignatureEvent.denominator)
        default:
            break
        }
    }
    return ret
}
