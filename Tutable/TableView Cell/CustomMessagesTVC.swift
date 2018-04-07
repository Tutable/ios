//
//  CustomMessagesTVC.swift
//  Tutable
//
//  Created by Amisha on 3/24/18.
//  Copyright © 2018 Hash Technocrats. All rights reserved.
//

import UIKit

class CustomMessagesTVC: UITableViewCell {
    
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var statusImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageBtn.addCircularRadiusOfView()
        statusImgView.addCircularRadiusOfView()
        statusImgView.applyBorderOfView(width: 2, borderColor: colorFromHex(hex: COLOR.WHITE_COLOR))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
