//
//  AccountDetailVC.swift
//  Tutable
//
//  Created by Keyur on 29/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class AccountDetailVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var accountNameTxt: UITextField!
    @IBOutlet weak var accountNumberTxt: UITextField!
    @IBOutlet weak var bsbTxt: UITextField!
    @IBOutlet weak var fnameTxt: UITextField!
    @IBOutlet weak var lnameTxt: UITextField!
    @IBOutlet weak var countryTxt: UITextField!
    @IBOutlet weak var stateTxt: UITextField!
    @IBOutlet weak var cityTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var postalCodeTxt: UITextField!
    @IBOutlet weak var dobTxt: UITextField!
    @IBOutlet weak var documentImgBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var _imgCompress:UIImage!
    var selectedDob : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        accountNameTxt.text = AppModel.shared.currentUser.name
        if AppModel.shared.currentUser.name.contains(" ")
        {
            let nameArr : [String] = AppModel.shared.currentUser.name.components(separatedBy: " ")
            fnameTxt.text = nameArr[0]
            if nameArr.count > 1
            {
                lnameTxt.text = nameArr[1]
            }
            
        }
        stateTxt.text = AppModel.shared.currentUser.address.state
        cityTxt.text = AppModel.shared.currentUser.address.suburb
        addressTxt.text = AppModel.shared.currentUser.address.location
        if AppModel.shared.currentUser.dob != 0.0
        {
            dobTxt.text = getDateStringFromServerTimeStemp(AppModel.shared.currentUser.dob)
            selectedDob = getDateFromTimeStamp(AppModel.shared.currentUser.dob)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
    }
    
    func setUIDesigning()
    {
        doneBtn.addCornerRadiusOfView(doneBtn.frame.size.height/2)
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToDOB(_ sender: Any) {
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
    
    @IBAction func clickToUploadDocument(_ sender: Any) {
        self.view.endEditing(true)
        uploadImage()
    }
    
    
    @IBAction func clickToDone(_ sender: Any) {
        self.view.endEditing(true)
        if accountNameTxt.text?.trimmed == ""
        {
            displayToast("Please enter account name")
        }
        else if accountNumberTxt.text?.trimmed == ""
        {
            displayToast("Please enter account number")
        }
        else if bsbTxt.text?.trimmed == ""
        {
            displayToast("Please enter BSB number")
        }
        else if fnameTxt.text?.trimmed == ""
        {
            displayToast("Please enter first name")
        }
        else if lnameTxt.text?.trimmed == ""
        {
            displayToast("Please enter last name")
        }
        else if countryTxt.text?.trimmed == ""
        {
            displayToast("Please enter country")
        }
        else if stateTxt.text?.trimmed == ""
        {
            displayToast("Please enter state")
        }
        else if cityTxt.text?.trimmed == ""
        {
            displayToast("Please enter city")
        }
        else if addressTxt.text?.trimmed == ""
        {
            displayToast("Please enter address")
        }
        else if postalCodeTxt.text?.trimmed == ""
        {
            displayToast("Please enter postal code")
        }
        else if selectedDob == nil || dobTxt.text == ""
        {
            displayToast("Please select date of birth")
        }
        else if getUserAge(date: selectedDob) < VALID_USER_AGE
        {
            displayToast("You need to be atleast 13 years old to be able to accept paymenmts")
        }
        else if _imgCompress == nil
        {
            displayToast("Please add a valid photo ID")
        }
        else
        {
            var finalDict : [String : Any] = [String : Any]()
            var accountDict : [String : Any] = [String : Any]()
            accountDict["accountHolder"] = accountNameTxt.text?.trimmed
            accountDict["accountNumber"] = accountNumberTxt.text?.trimmed
            accountDict["bsb"] = bsbTxt.text?.trimmed
            finalDict["account"] = accountDict
            
            var personalDict : [String : Any] = [String : Any]()
            var addressDict : [String : Any] = [String : Any]()
            addressDict["country"] = countryTxt.text?.trimmed
            addressDict["state"] = stateTxt.text?.trimmed
            addressDict["city"] = cityTxt.text?.trimmed
            addressDict["line1"] = addressTxt.text?.trimmed
            addressDict["postal"] = postalCodeTxt.text
            personalDict["address"] = addressDict
            
            var dobDict : [String : Any] = [String : Any]()
            dobDict["day"] = getDateStringFromDate(date: selectedDob, format: "dd")
            dobDict["month"] = getDateStringFromDate(date: selectedDob, format: "MM")
            dobDict["year"] = getDateStringFromDate(date: selectedDob, format: "YYYY")
            personalDict["dob"] = dobDict
            personalDict["firstName"] = fnameTxt.text?.trimmed
            personalDict["lastName"] = lnameTxt.text?.trimmed
            personalDict["type"] = "individual"
            if let ipAddress : String = getIPAddress()
            {
                personalDict["ip"] = ipAddress
            }
            finalDict["personalDetails"] = personalDict
            
            print(finalDict)
            if let imageData = UIImagePNGRepresentation(_imgCompress){
                APIManager.sharedInstance.serviceCallToCreateStripeBankAccount(finalDict, imgData: imageData, completion: {
                    displayToast("Account created successfully")
                    self.navigationController?.popViewController(animated: true)
                })
            }
            else{
                displayToast("Getting error in profile pic, please select another one.")
                return
            }
        }
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
        documentImgBtn.setBackgroundImage(_imgCompress.imageCropped(toFit: documentImgBtn.frame.size), for: .normal)
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
