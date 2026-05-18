import Foundation

enum PersistenceError: LocalizedError {
    case applicationSupportUnavailable
    case createDirectoryFailed(Error)
    case loadFailed(Error)
    case decodeFailed(Error)
    case encodeFailed(Error)
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .applicationSupportUnavailable:
            "Application Support is unavailable."
        case let .createDirectoryFailed(error):
            "Could not create app storage: \(error.localizedDescription)"
        case let .loadFailed(error):
            "Could not read saved state: \(error.localizedDescription)"
        case let .decodeFailed(error):
            "Saved state is invalid and was ignored: \(error.localizedDescription)"
        case let .encodeFailed(error):
            "Could not prepare saved state: \(error.localizedDescription)"
        case let .saveFailed(error):
            "Could not save app state: \(error.localizedDescription)"
        }
    }
}

final class PersistenceController {
    private let fileURL: URL?
    private let initializationError: PersistenceError?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fileURL = nil
            initializationError = .applicationSupportUnavailable
            return
        }

        let appDirectory = supportDirectory.appendingPathComponent("BandwidthGuard", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
            fileURL = appDirectory.appendingPathComponent("state.json")
            initializationError = nil
        } catch {
            fileURL = nil
            initializationError = .createDirectoryFailed(error)
        }
    }

    func load() -> Result<PersistedState?, PersistenceError> {
        guard let fileURL else {
            return .failure(initializationError ?? .applicationSupportUnavailable)
        }

        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return .success(nil)
            }
            let data = try Data(contentsOf: fileURL)
            return try .success(decoder.decode(PersistedState.self, from: data))
        } catch let decodingError as DecodingError {
            moveAsideInvalidState(at: fileURL)
            return .failure(.decodeFailed(decodingError))
        } catch {
            return .failure(.loadFailed(error))
        }
    }

    func save(_ state: PersistedState) -> PersistenceError? {
        guard let fileURL else {
            return initializationError ?? .applicationSupportUnavailable
        }

        do {
            let data = try encoder.encode(state)
            try data.write(to: fileURL, options: [.atomic])
            return nil
        } catch let encodingError as EncodingError {
            return .encodeFailed(encodingError)
        } catch {
            return .saveFailed(error)
        }
    }

    private func moveAsideInvalidState(at fileURL: URL) {
        let backupURL = fileURL.deletingLastPathComponent()
            .appendingPathComponent("state.invalid-\(Int(Date().timeIntervalSince1970)).json")
        try? FileManager.default.moveItem(at: fileURL, to: backupURL)
    }
}
