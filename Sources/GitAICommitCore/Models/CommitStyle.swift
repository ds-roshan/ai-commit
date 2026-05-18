import ArgumentParser

public enum CommitStyle: String, Codable, CaseIterable, ExpressibleByArgument, Sendable {
    case conventional
    case free
    case emoji

    public var promptInstructions: String {
        switch self {
        case .conventional:
            return """
            Use conventional commit format: type(scope): description
            Valid types: feat, fix, docs, style, refactor, test, chore, perf, ci, build
            The scope is optional. Keep the description under 72 characters.
            Examples: feat(ui): add dark mode toggle, fix(parser): handle empty input
            """
        case .free:
            return """
            Write a plain English description in imperative mood.
            Keep it under 72 characters. Be specific about what changed.
            Example: Remove unused imports from config module
            """
        case .emoji:
            return """
            Start with a single relevant emoji, then a space, then a description.
            Common emoji: ✨ new feature, 🐛 bug fix, 📝 docs, ♻️ refactor,
            🧪 tests, 🔧 config, ⚡️ performance, 🔒 security, 🚀 deploy
            Example: 🐛 Fix off-by-one error in pagination
            """
        }
    }

    public var displayName: String {
        switch self {
        case .conventional: return "Conventional (feat(scope): description)"
        case .free:         return "Free (plain English)"
        case .emoji:        return "Emoji (✨ description)"
        }
    }
}
