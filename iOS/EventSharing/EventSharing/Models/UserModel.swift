//
//  UserModel.swift
//  EventSharing
//
//  Created by certimeter on 11/04/23.
//

import Foundation

import UIKit

struct User: Codable {
    let username: String
    let email: String
    let image: Data?
    let favourites: Int
    let purchased: Int
    let created: Int
    let invitation: Int
    let newInvitation: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
        
        if let base64Image = try container.decodeIfPresent(String.self, forKey: .image) {
            if let imageData = Data(base64Encoded: base64Image) {
                self.image = imageData
            } else {
                throw DecodingError.dataCorruptedError(forKey: .image, in: container, debugDescription: "Invalid Base64-encoded image data")
            }
        } else {
            self.image = nil
        }
        if let favourite = try container.decodeIfPresent(Int.self, forKey: .favourites) {
            self.favourites = favourite
        } else {
            self.favourites = 0
        }
        if let purchased = try container.decodeIfPresent(Int.self, forKey: .purchased) {
            self.purchased = purchased
        } else {
            self.purchased = 0
        }
        if let created = try container.decodeIfPresent(Int.self, forKey: .created) {
            self.created = created
        } else {
            self.created = 0
        }
        if let invitation = try container.decodeIfPresent(Int.self, forKey: .invitation) {
            self.invitation = invitation
        } else {
            self.invitation = 0
        }
  
        if let newInvite = try container.decodeIfPresent(Bool.self, forKey: .newInvitation) {
            self.newInvitation = newInvite
        } else {
            self.newInvitation = false
        }
    }
}
