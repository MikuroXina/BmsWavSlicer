import SwiftUI
import UniformTypeIdentifiers

struct FocusedCommands: Commands {
    @FocusedValue(Project.self) private var project: Project?
    
    var body: some Commands {
        CommandMenu("Track") {
            Button("Add Track…") {
                guard let project = project else { return }
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = true
                panel.canChooseDirectories = false
                panel.allowedContentTypes = [.wav]
                if panel.runModal() == .OK {
                    for url in panel.urls {
                        project.addTrack(url)
                    }
                }
            }
            .keyboardShortcut("M")
            .disabled(project == nil)
        }
    }
}
