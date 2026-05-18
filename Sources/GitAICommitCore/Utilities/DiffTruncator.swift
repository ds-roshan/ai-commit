public enum DiffTruncator {
    public static let maxBytes = 12_288  // 12 KB

    public static func truncate(_ diff: String) -> String {
        guard diff.utf8.count > maxBytes else { return diff }

        var result = ""
        var bytes = 0

        for line in diff.components(separatedBy: "\n") {
            let lineWithNewline = line + "\n"
            let lineBytes = lineWithNewline.utf8.count
            if bytes + lineBytes > maxBytes { break }
            result += lineWithNewline
            bytes += lineBytes
        }

        return result + "\n[diff truncated at 12 KB]"
    }
}
