//
//  StudentRegistration.swift
//  Tutable
//
//  Created by Keyur on 23/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class StudentRegistration: UIViewController, UITextFieldDelegate, PhotoSelectionDelegate {

    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var _PhotoSelectionVC:PhotoSelectionVC!
    var _imgCompress:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _PhotoSelectionVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        profilePicBtn.addCornerRadiusOfView(profilePicBtn.frame.size.height/2)
        saveBtn.addCornerRadiusOfView(saveBtn.frame.size.height/2)
    }
    
    // MARK: - Button click event
    @IBAction func clickToUploadPicture(_ sender: Any) {
        self.view.endEditing(true)
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSave(_ sender: Any) {
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
            
            if _imgCompress == nil
            {
                continueRegistration(Data())
            }
            else if let imageData = UIImagePNGRepresentation(_imgCompress){
                continueRegistration(imageData)
            }
            else{
                displayToast("Getting error in profile pic, please select another one.")
                return
            }
            
        }
    }
    
    func continueRegistration(_ imageData : Data)
    {
        APIManager.sharedInstance.serviceCallToRegister(imageData) {
            let vc : VerificationCodeVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "VerificationCodeVC") as! VerificationCodeVC
            self.navigationController?.pushViewController(vc, animated: true)
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
            clickToSave(self)
        }
        return true
    }
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        _imgCompress = nil
        profilePicBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
    }
    
    func onSelectPic(_ img: UIImage) {
        _imgCompress = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
        profilePicBtn.setBackgroundImage(_imgCompress.imageCropped(toFit: profilePicBtn.frame.size), for: .normal)
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
