//
//  CustomClassesCVC.swift
//  Tutable
//
//  Created by Amisha on 3/24/18.
//  Copyright © 2018 Hash Technocrats. All rights reserved.
//

import UIKit

class CustomClassesCVC: UICollectionViewCell {

    @IBOutlet weak var imgBtn: UIButton!
    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet weak var autherLbl: UILabel!
    @IBOutlet weak var Lbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        imgBtn.addCornerRadiusOfView(10.0)
        
    }

}
