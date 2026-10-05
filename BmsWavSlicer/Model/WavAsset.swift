import Foundation
import AVFoundation

struct WavAsset: Codable, Identifiable {
    let id: Track
    let file: AVAudioFile?
    
    init(id: Track, from url: URL) {
        self.id = id
        file = try? AVAudioFile(forReading: url)
    }
    
    func loadSamples() async -> AVReadOnlyAudioPCMBuffer? {
        guard let file = file else { return nil }
        return try? file.read(frameCount: AVAudioFrameCount(file.length))
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fileUrl = "file_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Track.self, forKey: .id)
        let url = try container.decode(URL.self, forKey: .fileUrl)
        file = try AVAudioFile(forReading: url)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(file?.url ?? URL(filePath: "."), forKey: .fileUrl)
    }
}
