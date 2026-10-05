import Foundation

enum QuantizeType: Codable, CaseIterable, Identifiable, CustomStringConvertible {
    case whole
    case half
    case quarter
    case oneEight
    case oneSixteen
    case oneThirthyTwo
    case oneSixtyFour
    
    var id: Self { self }
    
    var beatQuantum: Double {
        switch self {
        case .whole:
            return Double.infinity
        case .half:
            return 2
        case .quarter:
            return 1
        case .oneEight:
            return 0.5
        case .oneSixteen:
            return 0.25
        case .oneThirthyTwo:
            return 0.125
        case .oneSixtyFour:
            return 0.0625
        }
    }
    
    var description: String {
        switch self {
        case .whole:
            return "Whole"
        case .half:
            return "Half"
        case .quarter:
            return "Quarter"
        case .oneEight:
            return "1/8"
        case .oneSixteen:
            return "1/16"
        case .oneThirthyTwo:
            return "1/32"
        case .oneSixtyFour:
            return "1/64"
        }
    }
}

struct QuantizeMode: Codable {
    var type: QuantizeType
    var isTriplet: Bool
    
    func toStride(_ resolution: TickResolution) -> MusicTick {
        return MusicTick(rawValue: Double(resolution.rawValue) * type.beatQuantum / (isTriplet ? 3.0 : 1.0))
    }
}
