//
//  ResetPasswordVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var tokenTxt: UITextField!
    @IBOutlet weak var newPasswordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        submitBtn.addCornerRadiusOfView(submitBtn.frame.size.height/2)
    }
    
    // MARK: - Button click event
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSubmit(_ sender: Any) {
        self.view.endEditing(true)
        if tokenTxt.text?.trimmed == ""
        {
            displayToast("Please enter token")
        }
        else if newPasswordTxt.text?.trimmed == ""
        {
            displayToast("Please enter password")
        }
        else if confirmPasswordTxt.text?.trimmed != newPasswordTxt.text?.trimmed
        {
            displayToast("Password not same")
        }
        else
        {
            AppModel.shared.currentUser.password = newPasswordTxt.text
            AppModel.shared.currentUser.verificationCode = tokenTxt.text
            APIManager.sharedInstance.serviceCallToChangePassword({
                AppDelegate().sharedDelegate().navigateToDashboard()
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
