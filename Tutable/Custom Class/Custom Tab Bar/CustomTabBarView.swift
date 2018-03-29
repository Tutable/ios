//
//  CustomTabBarView.swift
//  Event Project
//
//  Created by Keyur on 20/07/17.
//  Copyright © 2017 AK Infotech. All rights reserved.
//

import UIKit

protocol CustomTabBarViewDelegate
{
    func tabSelectedAtIndex(index:Int)
}

class CustomTabBarView: UIView {

    @IBOutlet var btn1: UIButton!
    @IBOutlet var btn2: UIButton!
    @IBOutlet var btn3: UIButton!
    @IBOutlet var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    
    var delegate:CustomTabBarViewDelegate?
    var lastIndex : NSInteger!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    func initialize()
    {
        lastIndex = 0
    }
    
    @IBAction func tabBtnClicked(_ sender: Any)
    {
        let btn: UIButton? = (sender as? UIButton)
        lastIndex = (btn?.tag)!-1

        resetAllButton()
        selectTabButton()
    }

    func resetAllButton()
    {
        btn1.isSelected = false
        btn2.isSelected = false
        btn3.isSelected = false
        btn4.isSelected = false
        btn5.isSelected = false
        
        lbl1.isHighlighted = false
        lbl2.isHighlighted = false
        lbl3.isHighlighted = false
        lbl4.isHighlighted = false
        lbl5.isHighlighted = false
    }
    
    func selectTabButton()
    {
        switch lastIndex {
        case 0:
            btn1.isSelected = true
            lbl1.isHighlighted = true
            break
        case 1:
            btn2.isSelected = true
            lbl2.isHighlighted = true
            break
        case 2:
            btn3.isSelected = true
            lbl3.isHighlighted = true
            break
        case 3:
            btn4.isSelected = true
            lbl4.isHighlighted = true
            break
        case 4:
            btn5.isSelected = true
            lbl5.isHighlighted = true
            break
        default:
            break
            
        }
        delegate?.tabSelectedAtIndex(index: lastIndex)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    
}
