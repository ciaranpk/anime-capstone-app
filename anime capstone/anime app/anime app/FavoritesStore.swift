import Foundation

// Protocol demonstrating protocols + testability
protocol Persisting {
    associatedtype Item: Codable & Hashable
    func load() throws -> [Item]
    func save(_ items: [Item]) throws
}

enum PersistenceError: Error {
    case writeFailed
    case readFailed
}

final class FavoritesStore: Persisting {
    typealias Item = Anime

    static let shared = FavoritesStore()
    private init() {}

    private let fileName = "favorites.json"

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(fileName)
    }

    private let queue = DispatchQueue(label: "FavoritesStoreQueue", qos: .userInitiated)

    func load() throws -> [Anime] {
        let url = fileURL
        if !FileManager.default.fileExists(atPath: url.path) {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Anime].self, from: data)
            return decoded
        } catch {
            throw PersistenceError.readFailed
        }
    }

    func save(_ items: [Anime]) throws {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw PersistenceError.writeFailed
        }
    }

    // MARK: - Convenience API with closures (escaping)

    func add(_ anime: Anime, completion: @escaping (Result<[Anime], Error>) -> Void) {
        queue.async {
            do {
                var current = try self.load()
                if !current.contains(anime) {
                    current.append(anime)
                    try self.save(current)
                }
                DispatchQueue.main.async { completion(.success(current)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    func remove(_ anime: Anime, completion: @escaping (Result<[Anime], Error>) -> Void) {
        queue.async {
            do {
                var current = try self.load()
                current.removeAll { $0 == anime }
                try self.save(current)
                DispatchQueue.main.async { completion(.success(current)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    func loadAsync(completion: @escaping (Result<[Anime], Error>) -> Void) {
        queue.async {
            do {
                let items = try self.load()
                DispatchQueue.main.async { completion(.success(items)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
