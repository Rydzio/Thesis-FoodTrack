//
//  InviteCell.swift
//  FoodTrack
//
//  Created by Michał Rytych on 15/4/21.
//

import UIKit

protocol InviteCellDelegate: AnyObject {
    func didTapButton(at indexPath: IndexPath?, with title: String?)
}

class InviteCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    weak var delegate: InviteCellDelegate?
    var indexPath: IndexPath?
    private var title: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        title = button.titleLabel?.text
        delegate?.didTapButton(at: indexPath, with: title)
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
