//
//  EventModel.swift
//  EventSharing
//
//  Created by certimeter on 17/04/23.
//

import Foundation
import UIKit

struct Event: Codable, Hashable {
    let id: Int
    let title: String
    let latitude: Double
    let longitude: Double
    let address: String
    let date: String
    let tag: String
    let description: String
    var image: Data?
    var owner: String //IDUTENTEPROPRIETARIO
    let qrCode: Data?
    var max_partecipnt: Int?
    var num_partecipant: Int?
    var externalLink: String?
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        if let address = try container.decodeIfPresent(String.self, forKey: .address) {
            self.address = address
        }else {
            self.address = ""
        }
        //Date Formatter non necessario
        self.date = try container.decode(String.self, forKey: .date)
        self.tag = try container.decode(String.self, forKey: .tag)
        self.description = try container.decode(String.self, forKey: .description)
        //Conversione immagine evento
        if let base64Image = try container.decodeIfPresent(String.self, forKey: .image) {
            if let imageData = Data(base64Encoded: base64Image) {
                self.image = imageData
            } else {
                throw DecodingError.dataCorruptedError(forKey: .image, in: container, debugDescription: "Invalid Base64-encoded image data")
            }
        } else {
            self.image = nil
        }
        
        if let owner = try container.decodeIfPresent(String.self, forKey: .owner){
            self.owner = owner
        }else {
            self.owner = ""
        }
        //Conversione QRcode evento
        if let base64Image = try container.decodeIfPresent(String.self, forKey: .qrCode) {
            if let qrCodeData = Data(base64Encoded: base64Image) {
                self.qrCode = qrCodeData
            } else {
                throw DecodingError.dataCorruptedError(forKey: .qrCode, in: container, debugDescription: "Invalid Base64-encoded image data")
            }
        } else { self.qrCode = nil }
        
        if let maxPartecipant = try container.decodeIfPresent(Int.self, forKey: .max_partecipnt) {
            self.max_partecipnt = maxPartecipant
        }else { self.max_partecipnt = 0 }
        
        if let numPartecipant = try container.decodeIfPresent(Int.self, forKey: .num_partecipant) {
            self.num_partecipant = numPartecipant
        } else { self.num_partecipant = 0 }
        
        if let externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink) {
            self.externalLink = externalLink
        } else { self.externalLink = nil }
        
    }
    
    init(_ id: Int, _ title: String, _ latitude: Double, _ longitude: Double,
         _ address: String, _ date: String, _ tag: String, _ description: String,
         _ image: Data, _ owner: String, _ max_partecipnt: Int, _ num_partecipant: Int, _ externalLink: String) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.date = date
        self.tag = tag
        self.description = description
        self.image = image
        self.owner = owner
        self.max_partecipnt = max_partecipnt
        self.num_partecipant = num_partecipant
        self.externalLink = externalLink
        self.qrCode = nil
    }
}
