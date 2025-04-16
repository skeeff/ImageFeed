import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    let thumbSize: CGSize
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: URLSResult
}

struct URLSResult: Decodable {
    let full: String
    let small: String
}

struct LikeResult: Codable {
    let likedByUser: Bool
}

struct Like: Codable {
    let photo: LikeResult
}
