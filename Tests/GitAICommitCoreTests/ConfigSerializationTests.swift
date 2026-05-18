import Testing
import Foundation
@testable import GitAICommitCore

@Suite("AppConfig serialization")
struct ConfigSerializationTests {

    @Test("Round-trips each CommitStyle variant")
    func roundTripsAllStyles() throws {
        for style in CommitStyle.allCases {
            let original = AppConfig(style: style)
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(AppConfig.self, from: data)
            #expect(decoded.style == original.style)
        }
    }

    @Test("Missing file returns default config")
    func missingFileReturnsDefault() {
        let missing = URL(fileURLWithPath: "/tmp/ai-commit-nonexistent-\(UUID()).json")
        let config = ConfigService(path: missing).load()
        #expect(config.style == .conventional)
    }

    @Test("Corrupt JSON returns default config")
    func corruptJSONReturnsDefault() throws {
        let url = URL(fileURLWithPath: "/tmp/ai-commit-corrupt-\(UUID()).json")
        try "not json at all!!!".write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        let config = ConfigService(path: url).load()
        #expect(config.style == .conventional)
    }

    @Test("Saved config persists and is readable")
    func saveAndReload() throws {
        let url = URL(fileURLWithPath: "/tmp/ai-commit-test-\(UUID()).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let service = ConfigService(path: url)
        let original = AppConfig(style: .emoji)
        try service.save(original)
        let reloaded = service.load()
        #expect(reloaded.style == .emoji)
    }

    @Test("Saved file has 0600 permissions")
    func savedFileHasRestrictedPermissions() throws {
        let url = URL(fileURLWithPath: "/tmp/ai-commit-perms-\(UUID()).json")
        defer { try? FileManager.default.removeItem(at: url) }
        try ConfigService(path: url).save(AppConfig())
        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        let perms = attrs[.posixPermissions] as? Int
        #expect(perms == 0o600)
    }
}
