//
//  CustomSettingTVC.swift
//  Tutable
//
//  Created by Keyur on 03/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class CustomSettingTVC: UITableViewCell {

    @IBOutlet weak var imgBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var constraintWidthImgBtn: NSLayoutConstraint!
    @IBOutlet weak var seperateImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
