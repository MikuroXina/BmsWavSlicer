import Foundation

/// Global scoped ticks per beat.
struct TickResolution: Codable, Hashable {
    let rawValue: UInt16
}

/// Local scoped micro-seconds per beat.
struct Tempo: Codable, Hashable {
    let rawValue: UInt32

    var bpm: Double {
        60 * 1000 * 1000 / Double(rawValue)
    }
}

/// Absolute tick count from the start of music.
struct MusicTick: Codable, Hashable {
    let rawValue: Double
}

/// Absolute micro-second count.
struct MicroSecond: Codable, Hashable {
    let rawValue: UInt32
    
    func scaledX(_ xScale: Double) -> CGFloat {
        let widthPerMs = 1e-4
        return xScale * widthPerMs * Double(rawValue)
    }
}
