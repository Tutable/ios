//
//  AddTeacherProfileVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import DropDown

class AddTeacherProfileVC: UIViewController, TeacherAvailabilityDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var dobTxt: UITextField!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var aboutMeTxt: UITextField!
    @IBOutlet weak var addAvailabilityBtn: UIButton!
    @IBOutlet weak var suburbTxt: UITextField!
    @IBOutlet weak var stateBtn: UIButton!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    var selectedDob : Date!
    var _imgCompress:UIImage!
    var isBackDisplay : Bool = true
    
    var availabilityDict : [String : [String]] = [String : [String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn.isHidden = !isBackDisplay
        
        
        setUserDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        userProfilePicBtn.addCircularRadiusOfView()
        addAvailabilityBtn.addCornerRadiusOfView(5.0)
        continueBtn.addCornerRadiusOfView(continueBtn.frame.size.height/2)
        stateBtn.addCornerRadiusOfView(5.0)
        stateBtn.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.LIGHT_GRAY))
    }
    
    func setUserDetail()
    {
        if AppModel.shared.currentUser == nil
        {
            return
        }
        nameTxt.text = AppModel.shared.currentUser.name
        emailTxt.text = AppModel.shared.currentUser.email
        if emailTxt.text != ""
        {
            emailTxt.isUserInteractionEnabled = false
        }
        if AppModel.shared.currentUser.picture != ""
        {
            APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [userProfilePicBtn])
        }
        if AppModel.shared.currentUser.dob != 0.0
        {
            dobTxt.text = getDateStringFromServerTimeStemp(AppModel.shared.currentUser.dob)
            selectedDob = getDateFromTimeStamp(AppModel.shared.currentUser.dob)
        }
        
        
        aboutMeTxt.text = AppModel.shared.currentUser.bio
        switch AppModel.shared.currentUser.gender {
        case "male":
            genderSegment.selectedSegmentIndex = 0
            break
        case "female":
            genderSegment.selectedSegmentIndex = 1
            break
        case "other":
            genderSegment.selectedSegmentIndex = 2
            break
        default:
            break
        }
        availabilityDict = AppModel.shared.currentUser.availability
        
        let location : LocationModel = LocationModel.init(dict: AppModel.shared.currentUser.address.dictionary())
        suburbTxt.text = location.suburb.capitalized
        stateLbl.text = location.state.uppercased()
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToUploadProfilePic(_ sender: Any) {
        self.view.endEditing(true)
        uploadImage()
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
    
    @IBAction func clickToAddAvailability(_ sender: Any) {
        self.view.endEditing(true)
        let vc : TeacherAvailabilityVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherAvailabilityVC") as! TeacherAvailabilityVC
        vc.delegate = self
        if availabilityDict.count != 0
        {
            vc.finalTimeDict = availabilityDict
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToSelectState(_ sender: Any) {
        self.view.endEditing(true)
        let dropdown : DropDown = DropDown()
        dropdown.anchorView = stateBtn
        dropdown.dataSource = stateArr
        dropdown.selectionAction = { [weak self] (index, item) in
            self?.stateLbl.text = stateArr[index]
        }
        dropdown.show()
    }
    
    @IBAction func clickToContinue(_ sender: Any) {
        self.view.endEditing(true)
        if AppModel.shared.currentUser.picture == "" && _imgCompress == nil
        {
            displayToast("Please select your profile picture")
        }
        else if nameTxt.text == ""
        {
            displayToast("Please enter name")
        }
        else if selectedDob == nil || dobTxt.text == ""
        {
            displayToast("Please select date of birth")
        }
        else if getUserAge(date: selectedDob) < VALID_USER_AGE
        {
            displayToast("You need to be atleast 13 years old to register")
        }
        else if aboutMeTxt.text == ""
        {
            displayToast("Please enter about you")
        }
//        else if availabilityDict.count == 0
//        {
//            displayToast("Please add your availability")
//        }
        else if suburbTxt.text == ""
        {
            displayToast("Please enter suburb")
        }
        else if stateLbl.text == "" || stateLbl.text == "State"
        {
            displayToast("Please select state")
        }
        else
        {
            AppModel.shared.currentUser.name = nameTxt.text
            AppModel.shared.currentUser.dob = getTimestampFromDate(date: selectedDob)
            switch genderSegment.selectedSegmentIndex {
            case 0:
                AppModel.shared.currentUser.gender = "male"
                break
            case 1:
                AppModel.shared.currentUser.gender = "female"
                break
            case 2:
                AppModel.shared.currentUser.gender = "other"
                break
            default:
                break
            }
            
            AppModel.shared.currentUser.bio = aboutMeTxt.text
            AppModel.shared.currentUser.availability = availabilityDict
            
            var dict : [String : Any] = [String : Any]()
            dict["name"] = AppModel.shared.currentUser.name
            dict["dob"] = AppModel.shared.currentUser.dob
            dict["gender"] = AppModel.shared.currentUser.gender
            //dict["email"] = AppModel.shared.currentUser.email
            dict["bio"] = AppModel.shared.currentUser.bio
            dict["availability"] = AppModel.shared.currentUser.availability
            
            let location : LocationModel = LocationModel.init()
            location.state = stateLbl.text?.uppercased()
            location.suburb = suburbTxt.text?.capitalized
            dict["address"] = location.dictionary()
            
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
        APIManager.sharedInstance.serviceCallToUpdateTeacherDetail(dict, degreeData: Data(), pictureData: imageData, completion: {
            let vc : TeacherCertificationVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherCertificationVC") as! TeacherCertificationVC
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func selectedAvailability(dict: [String : [String]]) {
        print(dict)
        availabilityDict = dict
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
        userProfilePicBtn.setBackgroundImage(_imgCompress.imageCropped(toFit: userProfilePicBtn.frame.size), for: .normal)
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
