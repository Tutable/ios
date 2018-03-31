//
//  LoginVC.swift
//  Tutable
//
//  Created by Keyur on 23/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
        
        if Platform.isSimulator
        {
            if isStudentLogin()
            {
                
            }
            else
            {
                usernameTxt.text = "keyurdakbari@gmail.com"
                passwordTxt.text = "qqqq"
            }
        }
    }
    
    func setUIDesigning()
    {
        loginBtn.addCornerRadiusOfView(loginBtn.frame.size.height/2)
    }
    
    // MARK: - Button click event
    @IBAction func clickToLogin(_ sender: Any) {
        self.view.endEditing(true)
        if usernameTxt.text?.trimmed == ""
        {
            displayToast("Please enter email.")
        }
        else if !(usernameTxt.text?.isValidEmail)!
        {
            displayToast("Invalid email address.")
        }
        else if passwordTxt.text?.trimmed == ""
        {
            displayToast("Please enter password")
        }
        else
        {
            AppModel.shared.currentUser = UserModel.init(dict: [String : Any]())
            AppModel.shared.currentUser.email = usernameTxt.text
            AppModel.shared.currentUser.password = passwordTxt.text
            
            if isStudentLogin()
            {
                AppDelegate().sharedDelegate().navigateToDashboard()
            }
            else
            {
                APIManager.sharedInstance.serviceCallToLogin({ (code) in
                    if code == 100
                    {
                        if !isStudentLogin() && AppModel.shared.currentUser.firstLogin == 1
                        {
                            let vc : EditTeacherProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditTeacherProfileVC") as! EditTeacherProfileVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else
                        {
                            AppDelegate().sharedDelegate().navigateToDashboard()
                        }
                    }
                    else if code == 104
                    {
                        let vc : VerificationCodeVC = self.storyboard?.instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
                        vc.isFromLoginScreen = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
    }
    
    @IBAction func clickToForgotPassword(_ sender: Any) {
        self.view.endEditing(true)
        let vc : ForgotPasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToFacebook(_ sender: Any) {
        self.view.endEditing(true)
        AppDelegate().sharedDelegate().loginWithFacebook()
    }
    
    @IBAction func clickToGoogle(_ sender: Any) {
        self.view.endEditing(true)
        AppDelegate().sharedDelegate().loginWithGoogle()
    }
    
    @IBAction func clickToCreateNewAccount(_ sender: Any) {
        self.view.endEditing(true)
        let vc : RegistrationVC = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationVC
        self.navigationController?.pushViewController(vc, animated: true)
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
