import ArgumentParser
import GitAICommitCore

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct ConfigShowCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Display current configuration and model availability."
    )

    mutating func run() async throws {
        let config = ConfigService().load()
        let ai = AIService.shared
        let availability = await ai.availabilityDescription

        print("Style:  \(config.style.rawValue) — \(config.style.displayName)")
        print("Model:  \(availability)")
        print("Config: \(AppConfig.defaultPath.path)")
    }
}
