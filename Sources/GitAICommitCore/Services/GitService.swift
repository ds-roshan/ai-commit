import Foundation

public enum GitError: Error, LocalizedError {
    case noStagedChanges
    case commandFailed(String)

    public var errorDescription: String? {
        switch self {
        case .noStagedChanges:
            return "No staged changes found. Use 'git add' to stage files before running."
        case .commandFailed(let output):
            return "Git command failed: \(output)"
        }
    }
}

public struct GitService: Sendable {
    public init() {}

    public func getStagedDiff() throws -> String {
        let diff = try shell("git", "diff", "--staged")
        if diff.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw GitError.noStagedChanges
        }
        return diff
    }

    public func commit(message: String) throws {
        _ = try shell("git", "commit", "-m", message)
    }

    private func shell(_ args: String...) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = args

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        try process.run()
        process.waitUntilExit()

        let output = String(
            data: outPipe.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""

        if process.terminationStatus != 0 {
            let errOutput = String(
                data: errPipe.fileHandleForReading.readDataToEndOfFile(),
                encoding: .utf8
            ) ?? ""
            throw GitError.commandFailed(errOutput.isEmpty ? output : errOutput)
        }

        return output
    }
}
