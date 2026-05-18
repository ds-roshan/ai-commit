import ArgumentParser
import GitAICommitCore
import Foundation

@main
@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct AICommit: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ai-commit",
        abstract: "Generate AI-powered git commit messages using Apple Intelligence.",
        discussion: "Analyses staged changes and suggests commit messages generated on-device — no API key or internet required.",
        subcommands: [CommitCommand.self, ConfigCommand.self]
    )

    @Option(name: .shortAndLong, help: "Number of suggestions to generate (1–5).")
    var count: Int = 3

    @Option(name: .shortAndLong, help: "Commit style: conventional, free, or emoji.")
    var style: CommitStyle?

    @Flag(name: .long, help: "Output suggestions as JSON instead of interactive UI.")
    var json: Bool = false

    @Flag(name: .shortAndLong, help: "Skip confirmation prompts and print the top suggestion.")
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

        if json {
            printJSON(suggestions)
            return
        }

        if yes {
            guard let first = suggestions.first else {
                throw CleanExit.message("No suggestions were generated.")
            }
            print(first)
            return
        }

        if let picked = interactivePick(from: suggestions) {
            print("\nSelected: \(picked)")
        }
    }
}

func printJSON(_ suggestions: [String]) {
    let payload: [String: [String]] = ["suggestions": suggestions]
    if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]),
       let str = String(data: data, encoding: .utf8) {
        print(str)
    }
}

func interactivePick(from suggestions: [String]) -> String? {
    print("\nGenerated commit messages:\n")
    for (i, suggestion) in suggestions.enumerated() {
        print("  \(i + 1). \(suggestion)")
    }
    print("  q. Quit without selecting\n")

    while true {
        print("Enter number: ", terminator: "")
        fflush(stdout)
        guard let input = readLine()?.trimmingCharacters(in: .whitespaces) else { return nil }
        if input.lowercased() == "q" || input.lowercased() == "quit" { return nil }
        if let index = Int(input), (1...suggestions.count).contains(index) {
            return suggestions[index - 1]
        }
        print("Please enter a number between 1 and \(suggestions.count), or 'q' to quit.")
    }
}
