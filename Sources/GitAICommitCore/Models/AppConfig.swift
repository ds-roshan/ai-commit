import Foundation

public struct AppConfig: Codable, Sendable {
    public var style: CommitStyle

    public init(style: CommitStyle = .conventional) {
        self.style = style
    }

    public static let defaultPath: URL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".ai-commit.json")
}
