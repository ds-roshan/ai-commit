import FoundationModels

@Generable
public struct CommitSuggestionList {
    @Guide(description: "A list of git commit message suggestions, one per element")
    public var suggestions: [String]
}
