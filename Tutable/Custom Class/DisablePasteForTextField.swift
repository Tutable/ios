//
//  DisablePasteForTextField.swift
//  LIT NITE
//
//  Created by Keyur on 19/02/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class DisablePasteForTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

}
