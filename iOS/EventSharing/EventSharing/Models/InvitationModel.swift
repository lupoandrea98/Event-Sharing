import Foundation

struct Invitation: Codable {
    let id: Int
    let user1Image: Data
    let user2name: String
    let eventTitle: String
    let eventId: Int
    var newInvitation: Bool
    let state: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        if let base64Image = try container.decodeIfPresent(String.self, forKey: .user1Image) {
            if let imageData = Data(base64Encoded: base64Image) {
                self.user1Image = imageData
            } else {
                throw DecodingError.dataCorruptedError(forKey: .user1Image, in: container, debugDescription: "Invalid Base64-encoded image data")
            }
        } else {
            self.user1Image = Data()
        }
        if let username = try container.decodeIfPresent(String.self, forKey: .user2name) {
            self.user2name = username
        } else {
            self.user2name = ""
        }
        if let eventTitle = try container.decodeIfPresent(String.self, forKey: .eventTitle) {
            self.eventTitle = eventTitle
        } else {
            self.eventTitle = ""
        }
        self.eventId = try container.decode(Int.self, forKey: .eventId)
        self.newInvitation = try container.decode(Bool.self, forKey: .newInvitation)
        if let state = try container.decodeIfPresent(String.self, forKey: .state) {
            self.state = state
        } else {
            self.state = ""
        }
    }
}
