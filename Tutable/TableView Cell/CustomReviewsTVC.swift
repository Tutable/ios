//
//  CustomReviewsTVC.swift
//  Tutable
//
//  Created by Amisha on 3/24/18.
//  Copyright © 2018 Hash Technocrats. All rights reserved.
//

import UIKit

class CustomReviewsTVC: UITableViewCell {

    @IBOutlet weak var profileImgBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var starView: FloatRatingView!
    @IBOutlet weak var expandableLabel: ExpandableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImgBtn.addCircularRadiusOfView()
        starView.type = .floatRatings
        starView.editable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
