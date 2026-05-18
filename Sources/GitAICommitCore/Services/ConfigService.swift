import Foundation

public struct ConfigService: Sendable {
    private let path: URL

    public init(path: URL = AppConfig.defaultPath) {
        self.path = path
    }

    public func load() -> AppConfig {
        guard
            let data = try? Data(contentsOf: path),
            let config = try? JSONDecoder().decode(AppConfig.self, from: data)
        else {
            return AppConfig()
        }
        return config
    }

    public func save(_ config: AppConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: path, options: .atomic)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: path.path
        )
    }
}
