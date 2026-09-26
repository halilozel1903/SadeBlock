import SwiftUI
import SafariServices

@main
struct SadeBlockApp: App {
    var body: some Scene {
        WindowGroup { Dashboard() }
            .windowResizability(.contentSize)
    }
}

struct Dashboard: View {
    private let identifier = "local.halil.SadeBlock.Blocker"
    @Environment(\.scenePhase) private var scenePhase
    @State private var enabled: Bool?
    @State private var message = "Checking Safari status…"
    @State private var busy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 48)).foregroundStyle(.teal)
                VStack(alignment: .leading, spacing: 4) {
                    Text("SadeBlock").font(.largeTitle.bold())
                    Text("A calmer Safari.").foregroundStyle(.secondary)
                }
            }
            HStack {
                Circle().fill(enabled == true ? Color.green : Color.orange).frame(width: 10, height: 10)
                Text(enabled == true ? "Enabled in Safari" : enabled == false ? "Waiting for activation in Safari" : "Status unavailable")
            }
            VStack(alignment: .leading, spacing: 12) {
                Label("Blocks requests to known ad networks", systemImage: "hand.raised")
                Label("Limits common tracking services", systemImage: "eye.slash")
                Label("Hides known ad placements", systemImage: "rectangle.slash")
            }
            Text("Does not read your browsing history or collect and transmit your data.")
                .font(.callout).foregroundStyle(.secondary)
            Divider()
            Text("To get started, enable SadeBlock in Safari → Settings → Extensions.")
            HStack {
                Button("Open Safari Settings") {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: identifier) { error in
                        DispatchQueue.main.async {
                            if let error { message = "Could not open settings: \(error.localizedDescription). Go to Safari → Settings → Extensions." }
                        }
                    }
                }.buttonStyle(.borderedProminent).tint(.teal)
                Button("Reload Rules") { reload() }.disabled(busy)
                Button { refresh() } label: { Image(systemName: "arrow.clockwise") }
                    .help("Refresh status")
            }
            Text(message).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
            Text("If a website stops working, disable content blockers for that site in Safari’s website settings. Some in-video ads may remain.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(32).frame(width: 570)
        .onAppear { refresh() }
        .onChange(of: scenePhase) { phase in if phase == .active { refresh() } }
    }

    private func refresh() {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: identifier) { state, error in
            DispatchQueue.main.async {
                enabled = state?.isEnabled
                if let error { message = "The extension is not available yet: \(error.localizedDescription)" }
                else { message = state?.isEnabled == true ? "Protection is on. Reload open pages to apply the rules." : "Enable the extension in Safari Settings." }
            }
        }
    }

    private func reload() {
        busy = true
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: identifier) { error in
            DispatchQueue.main.async {
                busy = false
                if let error { message = "Could not reload rules: \(error.localizedDescription)" }
                else { message = "Rules loaded into Safari. Reload your open pages." }
            }
        }
    }
}
