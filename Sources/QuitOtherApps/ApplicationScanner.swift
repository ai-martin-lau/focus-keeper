import Foundation

@MainActor
final class ApplicationScanner: ObservableObject {
    @Published private(set) var apps: [AppInfo] = []
    @Published private(set) var isScanning = false

    func scan() {
        guard !isScanning else {
            return
        }

        isScanning = true

        Task.detached(priority: .userInitiated) {
            let scannedApps = Self.scanApplications()

            await MainActor.run {
                self.apps = scannedApps
                self.isScanning = false
            }
        }
    }

    nonisolated private static func scanApplications() -> [AppInfo] {
        let roots = [
            URL(fileURLWithPath: "/Applications"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications"),
            URL(fileURLWithPath: "/System/Applications")
        ]

        var appsByKey: [String: AppInfo] = [:]

        for root in roots where FileManager.default.fileExists(atPath: root.path) {
            let options: FileManager.DirectoryEnumerationOptions = [
                .skipsHiddenFiles,
                .skipsPackageDescendants
            ]

            guard let enumerator = FileManager.default.enumerator(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey],
                options: options
            ) else {
                continue
            }

            for case let url as URL in enumerator {
                guard url.pathExtension.lowercased() == "app", let app = AppInfo(bundleURL: url) else {
                    continue
                }

                if appsByKey[app.identityKey] == nil {
                    appsByKey[app.identityKey] = app
                }
            }
        }

        return appsByKey.values.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
}
