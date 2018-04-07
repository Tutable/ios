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
        if Platform.isSimulator
        {
            if isStudentLogin()
            {
                usernameTxt.text = "testyear17@gmail.com"
                passwordTxt.text = "qqqq"
            }
            else
            {
                usernameTxt.text = "keyurdakbari@gmail.com"
//                usernameTxt.text = "testyear16@gmail.com"
                passwordTxt.text = "aaaa"
            }
        }

    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
        
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
            
            APIManager.sharedInstance.serviceCallToLogin({ (code) in
                if code == 100
                {
                    if isStudentLogin()
                    {
                        AppDelegate().sharedDelegate().navigateToDashboard()
                    }
                    else
                    {
                        APIManager.sharedInstance.serviceCallToGetCertificate {
                            let redirectionType : Int = AppDelegate().sharedDelegate().redirectAfterTeacherRegistration()
                            if redirectionType == 0
                            {
                                AppDelegate().sharedDelegate().navigateToDashboard()
                            }
                            else if redirectionType == 1
                            {
                                let vc : EditTeacherProfileVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "EditTeacherProfileVC") as! EditTeacherProfileVC
                                vc.isBackDisplay = false
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else if redirectionType == 2
                            {
                                let vc : TeacherCertificationVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherCertificationVC") as! TeacherCertificationVC
                                vc.isBackDisplay = false
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else if redirectionType == 3
                            {
                                let vc : TeacherQulificationVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherQulificationVC") as! TeacherQulificationVC
                                vc.isBackDisplay = false
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
                else if code == 104
                {
                    let vc : VerificationCodeVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
                    vc.isFromLoginScreen = true
                    vc.tokenType = 1
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    @IBAction func clickToForgotPassword(_ sender: Any) {
        self.view.endEditing(true)
        let vc : ForgotPasswordVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
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
        if isStudentLogin()
        {
            let vc : StudentRegistration = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "StudentRegistration") as! StudentRegistration
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            let vc : RegistrationVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationVC
            self.navigationController?.pushViewController(vc, animated: true)
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
