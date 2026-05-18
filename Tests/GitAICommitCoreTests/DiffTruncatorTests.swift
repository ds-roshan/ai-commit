import Testing
@testable import GitAICommitCore

@Suite("DiffTruncator")
struct DiffTruncatorTests {

    @Test("Short diff is returned unchanged")
    func shortDiffUnchanged() {
        let diff = "diff --git a/foo.swift b/foo.swift\n+let x = 1\n"
        let result = DiffTruncator.truncate(diff)
        #expect(result == diff)
    }

    @Test("Long diff is truncated and ends with marker")
    func longDiffTruncated() {
        let line = String(repeating: "x", count: 100) + "\n"
        let diff = String(repeating: line, count: 200)  // ~20 KB
        let result = DiffTruncator.truncate(diff)
        #expect(result.utf8.count < diff.utf8.count)
        #expect(result.hasSuffix("[diff truncated at 12 KB]"))
    }

    @Test("Truncated diff stays within byte limit")
    func truncatedDiffWithinLimit() {
        let line = String(repeating: "a", count: 200) + "\n"
        let diff = String(repeating: line, count: 100)  // ~20 KB
        let result = DiffTruncator.truncate(diff)
        // Allow for the truncation marker overhead
        #expect(result.utf8.count <= DiffTruncator.maxBytes + 100)
    }

    @Test("Truncation lands on a line boundary")
    func truncationOnLineBoundary() {
        let line = String(repeating: "b", count: 512) + "\n"
        let diff = String(repeating: line, count: 30)  // ~15 KB
        let result = DiffTruncator.truncate(diff)
        let contentBeforeMarker = result.components(separatedBy: "\n[diff truncated at 12 KB]").first ?? ""
        // Every line in content (except the last empty split) should match original lines
        for line in contentBeforeMarker.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
            #expect(line == String(repeating: "b", count: 512))
        }
    }

    @Test("Diff at exactly max bytes is not truncated")
    func exactlyMaxBytes() {
        let lineContent = String(repeating: "c", count: 127)  // 127 + 1 newline = 128 bytes
        let line = lineContent + "\n"
        // 12288 / 128 = 96 lines exactly
        let diff = String(repeating: line, count: 96)
        #expect(diff.utf8.count == DiffTruncator.maxBytes)
        let result = DiffTruncator.truncate(diff)
        #expect(result == diff)
    }
}
