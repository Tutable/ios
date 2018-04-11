//
//  VerificationCodeVC.swift
//  Tutable
//
//  Created by Keyur on 23/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class VerificationCodeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var verificationCodeTxt: UITextField!
    @IBOutlet weak var verificationLbl: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var timer : Timer = Timer()
    var timeValue : Int = 59
    var isFromLoginScreen : Bool = false
    var tokenType : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUIDesigning()
    }

    
    func setUIDesigning()
    {
        doneBtn.addCornerRadiusOfView(5.0)
        
        verificationCodeTxt.attributedPlaceholder = NSAttributedString(string: verificationCodeTxt.placeholder!,
                                                            attributes: [NSAttributedStringKey.foregroundColor: colorFromHex(hex: COLOR.APP_COLOR)])
        
        verificationLbl.text = "A text message with a verification code\nwas just sent to your " + AppModel.shared.currentUser.email
        
        if isFromLoginScreen
        {
            serviceCalledForResendOTP()
        }
        else{
            startVerificationTimer()
        }
    }
    
    func startVerificationTimer()
    {
        resendBtn.setTitle("Please wait 1:00", for: .normal)
        resendBtn.isUserInteractionEnabled = false
        timeValue = 59
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateVerificationTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateVerificationTime()
    {
        let minute : Int = (timeValue%3600)/60
        let second : Int = (timeValue%3600)%60
        resendBtn.setTitle(String(format: "Please wait %d:%d", minute,second), for: .normal)
        timeValue -= 1
        if timeValue < 0
        {
            timer.invalidate()
            resendBtn.isUserInteractionEnabled = true
            resendBtn.setTitle("Resend", for: .normal)
        }
    }
    
    // MARK: - Button click event
    
    @IBAction func clickToDone(_ sender: Any)
    {
        self.view.endEditing(true)
        if (verificationCodeTxt.text?.count)! < 4 {
            displayToast("Please enter verification code")
        }
        else
        {
            serviceCalledForVerifyOTP()
        }
    }
    
    @IBAction func clickToResendCode(_ sender: Any)
    {
        self.view.endEditing(true)
        serviceCalledForResendOTP()
    }
    
    @IBAction func clickToBack(_ sender: Any)
    {
        self.view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength:Int = 6
        var str:String = ""
        if(string == ""){
            return true
        }
        if(textField == verificationCodeTxt){
            str = verificationCodeTxt.text!
        }
        else{
            return true
        }
        return str.count < maxLength
    }
    
    // MARK: - Service called
    func serviceCalledForVerifyOTP()
    {
        APIManager.sharedInstance.serviceCallToVerifyCode(verificationCodeTxt.text!) {
            if isStudentLogin()
            {
                let vc : WelcomePageVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "WelcomePageVC") as! WelcomePageVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                let vc : AddTeacherProfileVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "AddTeacherProfileVC") as! AddTeacherProfileVC
                vc.isBackDisplay = false
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }
    }
    
    func serviceCalledForResendOTP()
    {
        APIManager.sharedInstance.serviceCallToResendVerifyCode(tokenType, completion: {
            displayToast("Code is sent to your email address, please verify now.")
        })
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
