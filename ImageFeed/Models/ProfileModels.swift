import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstname: String
    let lastname: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey{
        case username = "username"
        case firstname = "first_name"
        case lastname = "last_name"
        case bio = "bio"
        
    }
}

struct Profile {
    let profileResult: ProfileResult
    var username: String { profileResult.username }
    var name: String { profileResult.firstname + " " + (profileResult.lastname ?? "")}
    var loginName: String {"@" + profileResult.username }
    var bio: String { profileResult.bio ?? ""  }
    
}

struct UserResult: Codable {
    let profileImage: UserImage
}

struct UserImage: Codable {
    let small: String
    let medium: String
    let large: String
}
