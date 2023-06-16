//
//  CustomTextField.swift
//  EventSharing
//
//  Created by certimeter on 19/05/23.
//

import Foundation
import UIKit

@IBDesignable

class CustomTextField: UITextField {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customSetUp()
    }
  
    func customSetUp(){
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.borderWidth = 1
    }
}
