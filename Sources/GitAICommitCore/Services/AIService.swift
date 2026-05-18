import Foundation
import FoundationModels

public enum ModelAvailabilityError: Error, LocalizedError {
    case appleIntelligenceNotEnabled
    case deviceNotEligible
    case modelNotReady

    public var errorDescription: String? {
        switch self {
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled. Go to System Settings > Apple Intelligence & Siri to enable it."
        case .deviceNotEligible:
            return "This device is not eligible for Apple Intelligence. Apple Silicon (M1 or later) is required."
        case .modelNotReady:
            return "The Apple Intelligence model is not ready yet. It may still be downloading — try again shortly."
        }
    }
}

public actor AIService {
    public static let shared = AIService()

    private init() {}

    public func checkAvailability() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            return
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                throw ModelAvailabilityError.appleIntelligenceNotEnabled
            case .deviceNotEligible:
                throw ModelAvailabilityError.deviceNotEligible
            case .modelNotReady:
                throw ModelAvailabilityError.modelNotReady
            @unknown default:
                throw ModelAvailabilityError.modelNotReady
            }
        }
    }

    // Prewarms a session to reduce first-token latency on the first real request.
    public func prewarm() {
        let session = LanguageModelSession()
        session.prewarm()
    }

    public func generateSuggestions(
        diff: String,
        style: CommitStyle,
        count: Int
    ) async throws -> [String] {
        let truncated = DiffTruncator.truncate(diff)
        let prompt = buildPrompt(diff: truncated, style: style, count: count)
        let session = LanguageModelSession()
        let result = try await session.respond(to: prompt, generating: CommitSuggestionList.self)
        return Array(result.content.suggestions.prefix(count))
    }

    public var availabilityDescription: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return "Available"
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled: return "Unavailable (Apple Intelligence not enabled)"
            case .deviceNotEligible:           return "Unavailable (device not eligible)"
            case .modelNotReady:               return "Unavailable (model not ready)"
            @unknown default:                  return "Unavailable (unknown reason)"
            }
        }
    }

    private func buildPrompt(diff: String, style: CommitStyle, count: Int) -> String {
        """
        Analyze the following git diff and generate exactly \(count) commit message suggestion(s).

        Style instructions:
        \(style.promptInstructions)

        Additional guidelines:
        - Use imperative mood ("add" not "added", "fix" not "fixed")
        - Be specific — reference what changed, not just that something changed
        - Each suggestion must be distinct

        Git diff:
        ```
        \(diff)
        ```
        """
    }
}
