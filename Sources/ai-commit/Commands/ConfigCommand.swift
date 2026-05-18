import ArgumentParser
import GitAICommitCore

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct ConfigCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "config",
        abstract: "Manage git-ai-commit settings.",
        subcommands: [ConfigShowCommand.self, ConfigSetStyleCommand.self]
    )
}
