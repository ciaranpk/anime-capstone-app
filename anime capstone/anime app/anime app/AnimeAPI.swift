import Foundation

final class AnimeAPI {
    static let shared = AnimeAPI()
    private init() {}

    enum APIError: Error {
        case invalidURL
        case requestFailed
        case decodingFailed
        case unknown
    }

    // MARK: - Public

    /// Fetch a list of anime. Uses mock data by default to keep it simple.
    /// Set `useMock = false` to hit a real endpoint (example Jikan v4).
    func fetchAnimeList(useMock: Bool = true, completion: @escaping (Result<[Anime], Error>) -> Void) {
        if useMock {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                completion(.success(self.mockAnime()))
            }
            return
        }

        // Example public API (Jikan v4): https://api.jikan.moe/v4/top/anime
        let urlString = "https://api.jikan.moe/v4/top/anime"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let data else {
                completion(.failure(APIError.requestFailed))
                return
            }

            do {
                // Jikan returns { data: [Anime] }
                struct Response: Decodable {
                    let data: [Anime]
                }
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(decoded.data))
            } catch {
                completion(.failure(APIError.decodingFailed))
            }
        }.resume()
    }
    
    func searchAnime(query: String, completion: @escaping (Result<[Anime], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.success([]))
            return
        }

        func makeRequest(retryCount: Int) {
            guard let url = APIEndpoint.search(query: query).url else {
                completion(.failure(APIError.invalidURL))
                return
            }
            print("AnimeAPI.searchAnime URL:", url.absoluteString)
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error as? URLError, error.code == .timedOut, retryCount > 0 {
                    // Retry once after a short backoff
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        makeRequest(retryCount: retryCount - 1)
                    }
                    return
                }
                if let error {
                    completion(.failure(error))
                    return
                }
                guard let data else {
                    completion(.failure(APIError.requestFailed))
                    return
                }
                do {
                    struct Response: Decodable { let data: [Anime] }
                    let decoded = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(APIError.decodingFailed))
                }
            }.resume()
        }

        makeRequest(retryCount: 1)
    }

    // MARK: - Mock

    private func mockAnime() -> [Anime] {
        return [
            Anime(id: 1, title: "Fullmetal Alchemist: Brotherhood", synopsis: "Two brothers search for the Philosopher's Stone after an attempt to revive their deceased mother goes awry.", imageURL: URL(string: "https://placehold.co/200x280?text=FMA")),
            Anime(id: 2, title: "Attack on Titan", synopsis: "Humanity fights for survival against man-eating giants known as Titans.", imageURL: URL(string: "https://placehold.co/200x280?text=AoT")),
            Anime(id: 3, title: "Demon Slayer", synopsis: "A boy becomes a demon slayer after his family is slaughtered and his sister is turned into a demon.", imageURL: URL(string: "https://placehold.co/200x280?text=DS")),
            Anime(id: 4, title: "My Hero Academia", synopsis: "A boy born without superpowers in a world of heroes enrolls in a prestigious hero academy.", imageURL: URL(string: "https://placehold.co/200x280?text=MHA")),
            Anime(id: 5, title: "Jujutsu Kaisen", synopsis: "A high schooler swallows a cursed object and joins a secret organization of sorcerers.", imageURL: URL(string: "https://placehold.co/200x280?text=JJK")),
            Anime(id: 6, title: "One Piece", synopsis: "Monkey D. Luffy sails to find the ultimate treasure and become the Pirate King.", imageURL: URL(string: "https://placehold.co/200x280?text=OP")),
            Anime(id: 7, title: "Naruto", synopsis: "A young ninja seeks recognition and dreams of becoming the Hokage.", imageURL: URL(string: "https://placehold.co/200x280?text=Naruto")),
            Anime(id: 8, title: "Death Note", synopsis: "A student discovers a notebook that kills anyone whose name is written in it.", imageURL: URL(string: "https://placehold.co/200x280?text=DN")),
            Anime(id: 9, title: "Steins;Gate", synopsis: "A group of friends accidentally invent a method of sending messages to the past.", imageURL: URL(string: "https://placehold.co/200x280?text=SG")),
            Anime(id: 10, title: "Hunter x Hunter", synopsis: "A young boy becomes a Hunter to find his missing father.", imageURL: URL(string: "https://placehold.co/200x280?text=HxH")),
            Anime(id: 11, title: "Sword Art Online", synopsis: "Players are trapped in a virtual reality MMORPG where death in the game means death in real life.", imageURL: URL(string: "https://placehold.co/200x280?text=SAO")),
            Anime(id: 12, title: "Haikyuu!!", synopsis: "A volleyball team's rise to the top led by an undersized but determined player.", imageURL: URL(string: "https://placehold.co/200x280?text=Haikyuu")),
            Anime(id: 13, title: "Mob Psycho 100", synopsis: "A powerful psychic tries to live a normal life under his mentor's guidance.", imageURL: URL(string: "https://placehold.co/200x280?text=Mob")),
            Anime(id: 14, title: "Cowboy Bebop", synopsis: "Bounty hunters travel through space in search of their next payday.", imageURL: URL(string: "https://placehold.co/200x280?text=Bebop")),
            Anime(id: 15, title: "Vinland Saga", synopsis: "A young warrior seeks revenge and grapples with the true meaning of war and peace.", imageURL: URL(string: "https://placehold.co/200x280?text=Vinland"))
        ]
    }
}
