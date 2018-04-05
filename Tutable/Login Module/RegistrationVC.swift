//
//  RegistrationVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class RegistrationVC: UIViewController {

    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
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
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSubmit(_ sender: Any) {
        self.view.endEditing(true)
        if nameTxt.text?.trimmed == ""
        {
            displayToast("Please enter name.")
        }
        else if emailTxt.text?.trimmed == ""
        {
            displayToast("Please enter email.")
        }
        else if !(emailTxt.text?.isValidEmail)!
        {
            displayToast("Invalid email address.")
        }
        else if passwordTxt.text?.trimmed == ""
        {
            displayToast("Please enter password")
        }
        else if confirmPasswordTxt.text?.trimmed != passwordTxt.text?.trimmed
        {
            displayToast("Password not same")
        }
        else
        {
            AppModel.shared.currentUser = UserModel.init(dict: [String : Any]())
            AppModel.shared.currentUser.name = nameTxt.text
            AppModel.shared.currentUser.email = emailTxt.text
            AppModel.shared.currentUser.password = passwordTxt.text
            
            APIManager.sharedInstance.serviceCallToRegister(Data()) {
                let vc : VerificationCodeVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
                vc.tokenType = 1
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - Textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTxt
        {
            emailTxt.becomeFirstResponder()
        }
        else if textField == emailTxt
        {
            passwordTxt.becomeFirstResponder()
        }
        else if textField == passwordTxt
        {
            confirmPasswordTxt.becomeFirstResponder()
        }
        else if textField == confirmPasswordTxt
        {
            clickToSubmit(self)
        }
        return true
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
