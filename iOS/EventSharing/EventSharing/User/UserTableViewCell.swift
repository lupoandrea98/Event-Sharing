//
//  UserTableViewCell2.swift
//  EventSharing
//
//  Created by certimeter on 23/05/23.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var checkMark: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = 10
        checkMark.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            checkMark.alpha = 1
        } else {
            checkMark.alpha = 0
        }
    }
    
}
