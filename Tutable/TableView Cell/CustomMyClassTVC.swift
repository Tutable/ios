//
//  CustomMyClassTVC.swift
//  Tutable
//
//  Created by Keyur on 02/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class CustomMyClassTVC: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var classImgBtn: UIButton!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceUnitLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellDesign()
    {
        layoutIfNeeded()
        outerView.addCornerRadiusOfView(10.0)
        classImgBtn.roundCorners([.topLeft, .topRight], radius: 10.0)
        outerView.setInnerViewShadow(colorFromHex(hex: COLOR.SHADOW_GRAY))
    }
    
}
