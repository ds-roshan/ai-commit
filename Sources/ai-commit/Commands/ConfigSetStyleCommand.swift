import ArgumentParser
import GitAICommitCore

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct ConfigSetStyleCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set-style",
        abstract: "Set the preferred commit message style.",
        discussion: "Available styles: conventional, free, emoji"
    )

    @Argument(help: "The commit style to use: conventional, free, or emoji.")
    var style: CommitStyle

    mutating func run() async throws {
        let service = ConfigService()
        var config = service.load()
        config.style = style
        try service.save(config)
        print("Style set to '\(style.rawValue)': \(style.displayName)")
    }
}
