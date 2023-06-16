//
//  EventInfoModel.swift
//  EventSharing
//
//  Created by certimeter on 21/04/23.
//

import Foundation

struct EventInfo {
    var id: Int
    var title: String
    var location: String
    var date: String
    var tag: String
    var description: String
    var image: Data?
    var owner: String //IDUTENTEPROPRIETARIO
    var qrCode: Data?
    var maxPartecipant: Int?
}

