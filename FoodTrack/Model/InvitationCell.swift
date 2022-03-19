//
//  InvitationTableViewCell.swift
//  FoodTrack
//
//  Created by Michał Rytych on 9/4/21.
//

import UIKit

protocol InvitationCellDelegate: AnyObject {
    func didTapButton(at indexPath: IndexPath?, with title: String?)
}

class InvitationCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    weak var delegate: InvitationCellDelegate?
    var indexPath: IndexPath?
    private var title: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didTapLeftButton(_ sender: UIButton) {
        title = leftButton.titleLabel?.text
        delegate?.didTapButton(at: indexPath, with: title)
    }
    
    @IBAction func didTapRightButton(_ sender: UIButton) {
        title = rightButton.titleLabel?.text
        delegate?.didTapButton(at: indexPath, with: title)
    }
    
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
