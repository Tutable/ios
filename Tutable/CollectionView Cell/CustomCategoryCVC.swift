//
//  CustomCategoryCVC.swift
//  TutableApp
//
//  Created by Amisha on 3/24/18.
//  Copyright © 2018 Hash Technocrats. All rights reserved.
//

import UIKit

class CustomCategoryCVC: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.addCornerRadiusOfView(10.0)
    }

}
