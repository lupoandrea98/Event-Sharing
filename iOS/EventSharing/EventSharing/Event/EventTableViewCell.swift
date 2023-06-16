//
//  EventTableViewCell.swift
//  EventSharing
//
//  Created by certimeter on 14/04/23.
//

import UIKit

protocol EventTableViewCellDelegate: AnyObject {
    
}

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var imageMask: UIView!
    @IBOutlet weak var locationIcon: UIImageView!
    weak var delegate: EventTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
        self.backgroundImage.layer.cornerRadius = 20
        self.imageMask.layer.cornerRadius = 20
        let bgColorView = UIView()
        bgColorView.backgroundColor = .black.withAlphaComponent(0.1)
        self.selectedBackgroundView = bgColorView

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
