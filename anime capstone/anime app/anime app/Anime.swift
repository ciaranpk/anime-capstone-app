import Foundation

struct Anime: Codable, Hashable {
    let id: Int
    let title: String
    let synopsis: String?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id = "mal_id"
        case title
        case synopsis
        case images
    }

    enum ImagesKeys: String, CodingKey {
        case jpg
    }

    enum JPGKeys: String, CodingKey {
        case image_url
    }

    // Custom decoding to handle common Jikan-style JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = (try? container.decode(String.self, forKey: .title)) ?? "Untitled"
        synopsis = try? container.decode(String.self, forKey: .synopsis)

        // Parse nested image url if present
        if let images = try? container.nestedContainer(keyedBy: ImagesKeys.self, forKey: .images),
           let jpg = try? images.nestedContainer(keyedBy: JPGKeys.self, forKey: .jpg),
           let urlString = try? jpg.decode(String.self, forKey: .image_url),
           let url = URL(string: urlString) {
            imageURL = url
        } else {
            imageURL = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(synopsis, forKey: .synopsis)

        // Encode nested image url if available
        if let imageURL {
            var images = container.nestedContainer(keyedBy: ImagesKeys.self, forKey: .images)
            var jpg = images.nestedContainer(keyedBy: JPGKeys.self, forKey: .jpg)
            try jpg.encode(imageURL.absoluteString, forKey: .image_url)
        }
    }

    // Convenience init for mock data and manual creation
    init(id: Int, title: String, synopsis: String?, imageURL: URL?) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.imageURL = imageURL
    }
}
