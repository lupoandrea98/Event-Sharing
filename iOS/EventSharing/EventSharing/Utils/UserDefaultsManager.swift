//
//  UserDefaultsManager.swift
//  EventSharing
//
//  Created by certimeter on 11/04/23.
//

import Foundation

class UserDefaultsManager {
    // MARK: Lifecycle

    private init() {
        value = UserDefaults.standard.value(forKey: "userId") as? String
    }

    // MARK: Internal

    static let shared = UserDefaultsManager()

    var value: String? {
        didSet {
            setValue(value)
        }
    }

    // MARK: Private

    private func setValue(_ value: String?) {
        UserDefaults.standard.setValue(value, forKey: "userId")
    }
}
