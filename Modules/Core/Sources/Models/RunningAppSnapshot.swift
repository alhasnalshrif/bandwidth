import Foundation

public struct RunningAppSnapshot: Equatable, Sendable {
    public var bundleIdentifier: String
    public var name: String
    public var executablePath: String?
    public var category: AppCategory

    public init(bundleIdentifier: String, name: String, executablePath: String?, category: AppCategory) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.executablePath = executablePath
        self.category = category
    }
}
