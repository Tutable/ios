//
//  CustomUpcomingBookingTVC.swift
//  Tutable
//
//  Created by Keyur on 3/26/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class CustomUpcomingBookingTVC: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgBtn: UIButton!
    @IBOutlet weak var blackTransperentImgView: UIImageView!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var starBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    func setCellDesign()
    {
        layoutIfNeeded()
        outerView.addCornerRadiusOfView(10.0)
        blackTransperentImgView.roundCorners([.topLeft, .topRight], radius: 10.0)
        imgBtn.roundCorners([.topLeft, .topRight], radius: 10.0)
        outerView.setInnerViewShadow(colorFromHex(hex: COLOR.SHADOW_GRAY))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
