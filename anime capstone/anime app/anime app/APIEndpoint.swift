import Foundation

enum APIEndpoint {
    case topAnime
    case search(query: String)

    var url: URL? {
        switch self {
        case .topAnime:
            return URL(string: "https://api.jikan.moe/v4/top/anime")
        case .search(let query):
            // Jikan v4 search: https://api.jikan.moe/v4/anime?q=QUERY
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return URL(string: "https://api.jikan.moe/v4/anime?q=\(encoded)")
        }
    }
}
