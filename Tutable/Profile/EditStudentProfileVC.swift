//
//  EditStudentProfileVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class EditStudentProfileVC: UIViewController, UITextFieldDelegate, PhotoSelectionDelegate {

    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var dobTxt: UITextField!
    
    var _PhotoSelectionVC:PhotoSelectionVC!
    var _imgCompress:UIImage!
    var selectedDob : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _PhotoSelectionVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
        
        setUIDesigning()
    }

    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
    }
    
    
    func setUIDesigning()
    {
        profilePicBtn.addCircularRadiusOfView()
        saveBtn.addCornerRadiusOfView(saveBtn.frame.size.height/2)
        
        APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [profilePicBtn])
        nameTxt.text = AppModel.shared.currentUser.name
        if AppModel.shared.currentUser.email != ""
        {
            emailTxt.text = AppModel.shared.currentUser.email
            emailTxt.isUserInteractionEnabled = false
        }
        if AppModel.shared.currentUser.address.location != ""
        {
            addressTxt.text = AppModel.shared.currentUser.address.location
        }
        if AppModel.shared.currentUser.dob != 0.0
        {
            dobTxt.text = getDateStringFromServerTimeStemp(AppModel.shared.currentUser.dob)
            selectedDob = getDateFromTimeStamp(AppModel.shared.currentUser.dob)
        }
    }
    
    // MARK: - Button click event
    @IBAction func clickToUploadPicture(_ sender: Any) {
        self.view.endEditing(true)
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    @IBAction func clickToDob(_ sender: Any) {
        self.view.endEditing(true)
        if selectedDob == nil
        {
            selectedDob = Date()
        }
        let maxDate : Date = Date()
        DatePickerManager.shared.showPicker(title: "Select Date of Birth", selected: selectedDob, min: nil, max: maxDate) { (date, cancel) in
            if !cancel && date != nil {
                self.selectedDob = date!
                self.dobTxt.text = getDateStringFromDate(date: self.selectedDob)
            }
        }
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
        else if addressTxt.text?.trimmed == ""
        {
            displayToast("Please enter your address.")
        }
        else if selectedDob == nil
        {
            displayToast("Please select date of birth")
        }
        else
        {
            var dict : [String : Any] = [String : Any]()
            dict["name"] = nameTxt.text
            dict["email"] = emailTxt.text
            dict["address"] = addressTxt.text
            dict["dob"] = getTimestampFromDate(date: selectedDob)
            if _imgCompress == nil
            {
                continueUpdating(dict, Data())
            }
            else if let imageData = UIImagePNGRepresentation(_imgCompress){
                continueUpdating(dict, imageData)
            }
            else{
                displayToast("Getting error in profile pic, please select another one.")
                return
            }
        }
    }
    
    func continueUpdating(_ dict : [String : Any], _ imageData : Data)
    {
        APIManager.sharedInstance.serviceCallToUpdateStudentDetail(dict, pictureData: imageData) {
            displayToast("Profile updated successfully")
            AppModel.shared.firebaseCurrentUser.name =  AppModel.shared.currentUser.name
            AppModel.shared.firebaseCurrentUser.picture =  AppModel.shared.currentUser.picture
            AppDelegate().sharedDelegate().updateCurrentUserData()
            self.navigationController?.popViewController(animated: true)
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
            addressTxt.becomeFirstResponder()
        }
        else if textField == addressTxt
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
