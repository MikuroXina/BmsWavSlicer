import SwiftUI

@main struct BmsWavSlicerApp: App {
    var body: some Scene {
        DocumentGroup { project in
            RootView(project: project)
        } makeDocument: { _, _ in
            Project()
        }
        .commands {
            FocusedCommands()
        }
    }
}
