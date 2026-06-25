import Foundation

@MainActor
final class WhitelistStore: ObservableObject {
    @Published private(set) var items: [AppInfo] = []

    private let storageKey = "whitelist.apps.v1"

    init() {
        load()
    }

    func contains(_ app: AppInfo) -> Bool {
        items.contains { $0.identityKey == app.identityKey }
    }

    func add(_ app: AppInfo) {
        guard !contains(app) else {
            return
        }

        items.append(app)
        sortItems()
        save()
    }

    @discardableResult
    func addApp(at url: URL) -> Bool {
        guard let app = AppInfo(bundleURL: url) else {
            return false
        }

        add(app)
        return true
    }

    func remove(_ app: AppInfo) {
        items.removeAll { $0.identityKey == app.identityKey }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([AppInfo].self, from: data) else {
            items = []
            return
        }

        items = decoded
        sortItems()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func sortItems() {
        items.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
}
