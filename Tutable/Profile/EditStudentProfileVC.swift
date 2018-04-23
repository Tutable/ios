//
//  EditStudentProfileVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class EditStudentProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var dobTxt: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    
    var _imgCompress:UIImage!
    var selectedDob : Date!
    var isBackBtnDisplay : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUIDesigning()
    }

    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
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
        if isBackBtnDisplay == false
        {
            backBtn.isHidden = true
        }
        else
        {
            backBtn.isHidden = false
        }
    }
    
    // MARK: - Button click event
    @IBAction func clickToUploadPicture(_ sender: Any) {
        self.view.endEditing(true)
        uploadImage()
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
        if self.tabBarController != nil
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            AppDelegate().sharedDelegate().navigateToDashboard()
        }
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
        else if selectedDob == nil || dobTxt.text == ""
        {
            displayToast("Please select date of birth")
        }
        else if getUserAge(date: selectedDob) < VALID_USER_AGE
        {
            displayToast("You need to be atleast 13 years old to register")
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
            displayToast("You have successfully Logged In")
            if AppModel.shared.firebaseCurrentUser != nil
            {
                AppModel.shared.firebaseCurrentUser.name =  AppModel.shared.currentUser.name
                AppModel.shared.firebaseCurrentUser.picture =  AppModel.shared.currentUser.picture
                AppDelegate().sharedDelegate().updateCurrentUserData()
            }
            self.clickToBack(self)
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
    
    // MARK: - Upload Image
    func uploadImage()
    {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheet.addAction(cancelButton)
        
        let cameraButton = UIAlertAction(title: "Take Photo", style: .default)
        { _ in
            print("Camera")
            self.onCaptureImageThroughCamera()
        }
        actionSheet.addAction(cameraButton)
        
        let galleryButton = UIAlertAction(title: "Choose Existing Photo", style: .default)
        { _ in
            print("Gallery")
            self.onCaptureImageThroughGallery()
        }
        actionSheet.addAction(galleryButton)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc open func onCaptureImageThroughCamera()
    {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayToast("Your device has no camera")
            
        }
        else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            UIViewController.top?.present(imgPicker, animated: true, completion: {() -> Void in
            })
        }
    }
    
    @objc open func onCaptureImageThroughGallery()
    {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .photoLibrary
            self.present(imgPicker, animated: true, completion: {() -> Void in
            })
        }
    }
    
    func imagePickerController(_ imgPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgPicker.dismiss(animated: true, completion: {() -> Void in
        })
        
        let selectedImage: UIImage? = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        if selectedImage == nil {
            return
        }
        _imgCompress = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
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
