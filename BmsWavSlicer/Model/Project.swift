import Foundation
import UniformTypeIdentifiers
import System
import SwiftUI
import SwiftData
import AVFoundation

@Observable
final class Project: Codable {
    var resolution: TickResolution
    var xScale: Double
    var assets: [WavAsset]
    var rulerMarks: [RulerMark]
    var sliceMarks: [[SliceMark]]
    var quantizeMode: QuantizeMode

    init() {
        resolution = TickResolution(rawValue: 240)
        xScale = 1.0
        assets = []
        rulerMarks = defaultRulerMarks
        sliceMarks = []
        quantizeMode = QuantizeMode(type: .oneEight, isTriplet: false)
    }
    
    func addTrack(_ newWav: URL) {
        let newId = Track(rawValue: newWav.lastPathComponent)
        let newAsset = WavAsset(id: newId, from: newWav)
        assets.append(newAsset)
        sliceMarks.append([])
    }
}

extension Project: Document {
    static let readableContentTypes: [UTType] = [.json]

    func writer(configuration: sending WriteConfiguration) -> sending FileWrapperDocumentWriter<Data> {
        FileWrapperDocumentWriter(configuration) { snapshot, _ in
            FileWrapper(
                regularFileWithContents: snapshot
            )
        }
    }
    
    func snapshot(contentType: UTType) async throws -> sending Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(self)
        return data
    }
    
    func reader(configuration: sending ReadConfiguration) -> sending FileWrapperDocumentReader<Data> {
        FileWrapperDocumentReader(configuration) { fileWrapper in
            guard let data = fileWrapper.regularFileContents else {
                throw CocoaError(.fileReadCorruptFile)
            }
            return data
        }
    }
    
    @MainActor func apply(snapshot: sending Data, previous: sending Data?) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.allowsJSON5 = true
        let data = try decoder.decode(Project.self, from: snapshot)

        self.resolution = data.resolution
        self.xScale = data.xScale
        self.assets = data.assets
        self.rulerMarks = data.rulerMarks
        self.sliceMarks = data.sliceMarks
        self.quantizeMode = data.quantizeMode
    }
}

struct Track: Codable, Hashable {
    let rawValue: String
}

struct SliceMark: Codable, Hashable {
    let at: MicroSecond
    let track: Track
}
