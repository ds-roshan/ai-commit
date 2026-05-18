import ArgumentParser
import GitAICommitCore

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct CommitCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "commit",
        abstract: "Generate a commit message and apply it via git commit."
    )

    @Option(name: .shortAndLong, help: "Number of suggestions to generate (1–5).")
    var count: Int = 3

    @Option(name: .shortAndLong, help: "Commit style: conventional, free, or emoji.")
    var style: CommitStyle?

    @Flag(name: .shortAndLong, help: "Skip confirmation and commit with the top suggestion.")
    var yes: Bool = false

    mutating func run() async throws {
        let count = max(1, min(5, count))
        let config = ConfigService().load()
        let resolvedStyle = style ?? config.style

        let ai = AIService.shared
        try await ai.checkAvailability()
        await ai.prewarm()

        let git = GitService()
        let diff = try git.getStagedDiff()
        let suggestions = try await ai.generateSuggestions(diff: diff, style: resolvedStyle, count: count)

        let message: String

        if yes {
            guard let first = suggestions.first else {
                throw CleanExit.message("No suggestions were generated.")
            }
            message = first
        } else {
            guard let picked = interactivePick(from: suggestions) else {
                throw CleanExit.message("No message selected. Nothing committed.")
            }
            message = picked
        }

        try git.commit(message: message)
        print("Committed: \(message)")
    }
}
