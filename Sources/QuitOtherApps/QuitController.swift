import AppKit
import Foundation

struct QuitSummary {
    let quitRequestCount: Int
    let finderWindowCount: Int
    let finderError: String?
}

enum QuitController {
    static func quitOtherApps(whitelist: [AppInfo]) -> QuitSummary {
        let finderResult = closeFinderWindows()
        var quitRequestCount = 0
        let currentProcessID = ProcessInfo.processInfo.processIdentifier
        let currentBundleID = Bundle.main.bundleIdentifier ?? ""
        let currentProcessName = ProcessInfo.processInfo.processName

        for runningApp in NSWorkspace.shared.runningApplications {
            guard runningApp.activationPolicy == .regular else {
                continue
            }

            guard runningApp.processIdentifier != currentProcessID else {
                continue
            }

            let appName = runningApp.localizedName ?? ""
            let bundleID = runningApp.bundleIdentifier ?? ""
            let path = runningApp.bundleURL?.path

            guard !shouldKeepApp(
                appName: appName,
                bundleID: bundleID,
                path: path,
                whitelist: whitelist,
                currentBundleID: currentBundleID,
                currentProcessName: currentProcessName
            ) else {
                continue
            }

            if runningApp.terminate() {
                quitRequestCount += 1
            }
        }

        return QuitSummary(
            quitRequestCount: quitRequestCount,
            finderWindowCount: finderResult.windowCount,
            finderError: finderResult.errorMessage
        )
    }

    private static func shouldKeepApp(
        appName: String,
        bundleID: String,
        path: String?,
        whitelist: [AppInfo],
        currentBundleID: String,
        currentProcessName: String
    ) -> Bool {
        if bundleID == "com.apple.finder" || appName == "Finder" || appName == "访达" || appName == "訪達" {
            return true
        }

        if (!currentBundleID.isEmpty && bundleID == currentBundleID) || appName == currentProcessName {
            return true
        }

        return whitelist.contains {
            $0.matchesRunningApp(name: appName, bundleID: bundleID, path: path)
        }
    }

    private static func closeFinderWindows() -> (windowCount: Int, errorMessage: String?) {
        let source = """
        tell application "Finder"
            set finderWindowCount to count of windows
            close every window
            return finderWindowCount
        end tell
        """

        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else {
            return (0, "Could not create Finder automation script.")
        }

        let result = script.executeAndReturnError(&error)

        if let error {
            let message = error[NSAppleScript.errorMessage] as? String
            return (0, message ?? "Finder automation failed.")
        }

        return (Int(result.int32Value), nil)
    }
}
