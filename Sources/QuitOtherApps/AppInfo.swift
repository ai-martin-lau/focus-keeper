import Foundation

struct AppInfo: Codable, Hashable, Identifiable, Sendable {
    let name: String
    let bundleID: String
    let path: String

    var id: String {
        identityKey
    }

    var identityKey: String {
        if !bundleID.isEmpty {
            return "bundle:\(bundleID)"
        }

        return "path:\(standardizedPath)"
    }

    var standardizedPath: String {
        URL(fileURLWithPath: path).standardizedFileURL.path
    }

    var detailText: String {
        bundleID.isEmpty ? standardizedPath : bundleID
    }

    init(name: String, bundleID: String, path: String) {
        self.name = name
        self.bundleID = bundleID
        self.path = path
    }

    init?(bundleURL: URL) {
        let url = bundleURL.standardizedFileURL
        guard url.pathExtension.lowercased() == "app" else {
            return nil
        }

        let bundle = Bundle(url: url)
        let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let bundleName = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
        let fileName = url.deletingPathExtension().lastPathComponent
        let resolvedName = displayName?.nilIfEmpty ?? bundleName?.nilIfEmpty ?? fileName

        self.name = resolvedName
        self.bundleID = bundle?.bundleIdentifier ?? ""
        self.path = url.path
    }

    func matchesRunningApp(name runningName: String, bundleID runningBundleID: String, path runningPath: String?) -> Bool {
        if !bundleID.isEmpty && bundleID == runningBundleID {
            return true
        }

        if name == runningName {
            return true
        }

        if let runningPath, standardizedPath == URL(fileURLWithPath: runningPath).standardizedFileURL.path {
            return true
        }

        return false
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
