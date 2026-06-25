import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject private var scanner: ApplicationScanner
    @EnvironmentObject private var whitelist: WhitelistStore

    @State private var searchText = ""
    @State private var statusText = "Finder and this app are always kept."
    @State private var isDropTargeted = false
    @State private var showQuitConfirmation = false

    private var filteredApps: [AppInfo] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return scanner.apps
        }

        return scanner.apps.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
                $0.bundleID.localizedCaseInsensitiveContains(query) ||
                $0.path.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HStack(spacing: 0) {
                applicationsPanel
                    .frame(minWidth: 460)

                Divider()

                protectedAppsPanel
                    .frame(minWidth: 400)
            }
            Divider()
            statusBar
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(minWidth: 920, minHeight: 620)
        .onAppear {
            scanner.scan()
        }
        .alert("Quit other apps?", isPresented: $showQuitConfirmation) {
            Button("Quit apps", role: .destructive) {
                performQuit()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Finder windows will close. Protected apps stay open. Apps with unsaved changes may ask before quitting.")
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "app.badge.checkmark")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text("Quit Other Apps")
                    .font(.title2.weight(.semibold))
                Text("Choose what stays open, then close the rest.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                scanner.scan()
            } label: {
                Label(scanner.isScanning ? "Scanning" : "Rescan", systemImage: "arrow.clockwise")
            }
            .disabled(scanner.isScanning)
            .help("Scan installed applications again")

            Button {
                showQuitConfirmation = true
            } label: {
                Label("Quit apps", systemImage: "power")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .help("Close Finder windows and send quit requests to unprotected apps")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var applicationsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            panelHeader(
                title: "Applications",
                detail: scanner.isScanning ? "Scanning" : "\(filteredApps.count) found"
            )

            TextField("Search", text: $searchText)
                .textFieldStyle(.roundedBorder)

            if filteredApps.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "No matching apps",
                    detail: "Try a different app name or rescan Applications."
                )
            } else {
                List(filteredApps) { app in
                    ApplicationRow(
                        app: app,
                        isProtected: whitelist.contains(app),
                        action: {
                            whitelist.add(app)
                            statusText = "Protected \(app.name)."
                        }
                    )
                }
                .listStyle(.inset)
            }
        }
        .padding(18)
    }

    private var protectedAppsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            panelHeader(
                title: "Protected apps",
                detail: "\(whitelist.items.count + 2) kept"
            )

            dropZone

            VStack(alignment: .leading, spacing: 8) {
                Text("Always protected")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                BuiltInProtectedRow(
                    systemImage: "macwindow",
                    title: "Finder",
                    detail: "Windows close; Finder keeps running."
                )

                BuiltInProtectedRow(
                    systemImage: "app.dashed",
                    title: "Quit Other Apps",
                    detail: "This control panel stays open."
                )
            }
            .padding(.top, 2)

            Text("User protected")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if whitelist.items.isEmpty {
                EmptyStateView(
                    systemImage: "plus.app",
                    title: "No apps added yet",
                    detail: "Add from the list or drop .app files here."
                )
            } else {
                List(whitelist.items) { app in
                    ProtectedAppRow(
                        app: app,
                        removeAction: {
                            whitelist.remove(app)
                            statusText = "Removed protection for \(app.name)."
                        }
                    )
                }
                .listStyle(.inset)
            }
        }
        .padding(18)
        .onDrop(
            of: [UTType.fileURL.identifier],
            isTargeted: $isDropTargeted,
            perform: handleDrop(providers:)
        )
    }

    private var dropZone: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(
                isDropTargeted ? Color.accentColor : Color.secondary.opacity(0.45),
                style: StrokeStyle(lineWidth: 1, dash: [5, 4])
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDropTargeted ? Color.accentColor.opacity(0.08) : Color.clear)
            )
            .overlay {
                HStack(spacing: 8) {
                    Image(systemName: "plus.app")
                    Text("Drop apps to protect")
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .frame(height: 58)
            .accessibilityLabel("Drop apps to protect")
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func panelHeader(title: String, detail: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
            Spacer()
            Text(detail)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private func performQuit() {
        let summary = QuitController.quitOtherApps(whitelist: whitelist.items)
        var message = "Sent quit requests to \(summary.quitRequestCount) apps and closed \(summary.finderWindowCount) Finder windows."

        if let finderError = summary.finderError {
            message += " Finder: \(finderError)"
        }

        statusText = message
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        let fileProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }

        guard !fileProviders.isEmpty else {
            return false
        }

        for provider in fileProviders {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                let url: URL?

                if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else {
                    url = item as? URL
                }

                guard let url else {
                    return
                }

                DispatchQueue.main.async {
                    if whitelist.addApp(at: url) {
                        statusText = "Protected \(url.deletingPathExtension().lastPathComponent)."
                    } else {
                        statusText = "Only .app bundles can be added."
                    }
                }
            }
        }

        return true
    }
}

private struct ApplicationRow: View {
    let app: AppInfo
    let isProtected: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            AppIconView(path: app.path)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .lineLimit(1)
                Text(app.detailText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            Button(action: action) {
                Image(systemName: isProtected ? "checkmark.circle.fill" : "plus.circle")
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
            .disabled(isProtected)
            .help(isProtected ? "Already protected" : "Protect this app")
        }
        .padding(.vertical, 4)
    }
}

private struct ProtectedAppRow: View {
    let app: AppInfo
    let removeAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            AppIconView(path: app.path)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .lineLimit(1)
                Text(app.detailText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            Button(role: .destructive, action: removeAction) {
                Image(systemName: "minus.circle")
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.borderless)
            .help("Remove protection")
        }
        .padding(.vertical, 4)
    }
}

private struct BuiltInProtectedRow: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .lineLimit(1)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .help("Always protected")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.callout.weight(.semibold))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
