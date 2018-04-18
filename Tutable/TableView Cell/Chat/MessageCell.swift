//
//  MessageCell.swift
//  Check-Up
//
//  Created by Amisha on 05/10/17.
//  Copyright © 2017 Amisha. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var profilePicView: UIView!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var ConstraintHeightMessageView: NSLayoutConstraint!
    @IBOutlet weak var durationLbl: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var constraintHeaderWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightHeaderView: NSLayoutConstraint!
    @IBOutlet weak var statusImgView: UIImageView!
    @IBOutlet weak var arrowBtn: UIButton!
    
    @IBOutlet weak var constraintHeightExtraSpace: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerLbl.addCornerRadiusOfView(5.0)
        
        messageTxtView.isEditable = false
        messageTxtView.isSelectable = true
        messageTxtView.dataDetectorTypes = UIDataDetectorTypes.all
        
        statusImgView.addCircularRadiusOfView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
