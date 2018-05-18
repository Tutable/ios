//
//  EditTeacherProfileVC.swift
//  Tutable
//
//  Created by Keyur on 11/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import DropDown
import SDWebImage

struct PHOTO {
    static var USER_IMAGE = 1
    static var POLICE_IMAGE = 2
    static var CHILDREN_IMAGE = 3
    static var DEGREE_IMAGE = 4
}

class EditTeacherProfileVC: UIViewController, TeacherAvailabilityDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

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
    
    @IBOutlet weak var policeCheckBtn: UIButton!
    @IBOutlet weak var childrenCheckBtn: UIButton!
    
    @IBOutlet weak var relevantSegment: UISegmentedControl!
    @IBOutlet weak var qulificationTxt: UITextField!
    @IBOutlet weak var schoolTxt: UITextField!
    @IBOutlet weak var experienceearTxt: UITextField!
    @IBOutlet weak var degreeImgBtn: UIButton!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    var selectedDob : Date!
    var photoSelectionType : Int = 0
    var imgCompress:UIImage!
    var policeCheckImg:UIImage!
    var childrenCheckImg:UIImage!
    var degreeImg:UIImage!
    
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
        policeCheckBtn.addCornerRadiusOfView(5.0)
        childrenCheckBtn.addCornerRadiusOfView(5.0)
        degreeImgBtn.addCornerRadiusOfView(5.0)
    }
    
    func setUserDetail()
    {
        if AppModel.shared.currentUser == nil
        {
            return
        }
        APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [userProfilePicBtn])
//        if let police : String = AppModel.shared.currentUser.certs["policeCertificate"] as? String
//        {
//            APIManager.sharedInstance.serviceCallToGetPhoto(police, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [policeCheckBtn])
//        }
//        if let police : String = AppModel.shared.currentUser.certs["policeCertificate"] as? String
//        {
//            APIManager.sharedInstance.serviceCallToGetPhoto(police, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [policeCheckBtn])
//        }
        if getPoliceCertificate() != "" && getChildreanCertificate() != ""
        {
            setCertificateImage()
        }
        else
        {
            APIManager.sharedInstance.serviceCallToGetCertificate {
                self.setCertificateImage()
            }
        }
        nameTxt.text = AppModel.shared.currentUser.name
        emailTxt.text = AppModel.shared.currentUser.email
        if emailTxt.text != ""
        {
            emailTxt.isUserInteractionEnabled = false
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
        suburbTxt.text = location.suburb
        stateLbl.text = location.state
        if AppModel.shared.currentUser.experience > 0
        {
            experienceearTxt.text = String(AppModel.shared.currentUser.experience)
        }
        else
        {
            experienceearTxt.text = ""
        }
        if AppModel.shared.currentUser.qualification == "" && qulificationTxt.text == "" && AppModel.shared.currentUser.degreeAsset == ""
        {
            relevantSegment.selectedSegmentIndex = 1
        }
        else
        {
            relevantSegment.selectedSegmentIndex = 0
            qulificationTxt.text = AppModel.shared.currentUser.qualification
            schoolTxt.text = AppModel.shared.currentUser.school
            if AppModel.shared.currentUser.experience > 0
            {
                experienceearTxt.text = String(AppModel.shared.currentUser.experience)
            }
            else
            {
                experienceearTxt.text = ""
            }
            if AppModel.shared.currentUser.degreeAsset != ""
            {
                APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.degreeAsset, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [degreeImgBtn])
            }
        }
        setDegreeFields()
    }
    
    func setCertificateImage()
    {
        if getPoliceCertificate() != ""
        {
            APIManager.sharedInstance.serviceCallToGetCertificateImage(getPoliceCertificate(), btn: policeCheckBtn, completion: {
                self.policeCheckImg = self.policeCheckBtn.backgroundImage(for: .normal)
            })
        }
        if getChildreanCertificate() != ""
        {
            APIManager.sharedInstance.serviceCallToGetCertificateImage(getChildreanCertificate(), btn: childrenCheckBtn, completion: {
                self.childrenCheckImg = self.childrenCheckBtn.backgroundImage(for: .normal)
            })
        }
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
    
    @IBAction func clickToAddAvailability(_ sender: Any) {
        self.view.endEditing(true)
        let vc : TeacherAvailabilityVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherAvailabilityVC") as! TeacherAvailabilityVC
        vc.delegate = self
        if availabilityDict.count != 0
        {
            vc.finalTimeDict = availabilityDict
        }
        vc.isEditProfile = true
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
    
    @IBAction func clickToUploadProfilePic(_ sender: Any) {
        self.view.endEditing(true)
        photoSelectionType = PHOTO.USER_IMAGE
        uploadImage()
    }
    
    @IBAction func clickToUploadPoliceCheck(_ sender: Any) {
        self.view.endEditing(true)
        photoSelectionType = PHOTO.POLICE_IMAGE
        uploadImage()
    }
    
    @IBAction func clickToPoliceCheckURL(_ sender: Any) {
        self.view.endEditing(true)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string : POLICE_CHECK_URL)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func clickToChildrenCheck(_ sender: Any) {
        self.view.endEditing(true)
        photoSelectionType = PHOTO.CHILDREN_IMAGE
        uploadImage()
    }
    
    @IBAction func clickToChildrenCheckURL(_ sender: Any) {
        self.view.endEditing(true)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string : CHILDREN_CHECK_URL)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func clickToUploadDegreeImg(_ sender: Any) {
        self.view.endEditing(true)
        photoSelectionType = PHOTO.DEGREE_IMAGE
        uploadImage()
    }
    
    @IBAction func clickToChangeSegment(_ sender: Any) {
        setDegreeFields()
    }
    
    func setDegreeFields()
    {
        if relevantSegment.selectedSegmentIndex == 0
        {
            qulificationTxt.isUserInteractionEnabled = true
            schoolTxt.isUserInteractionEnabled = true
            degreeImgBtn.isUserInteractionEnabled = true
        }
        else
        {
            qulificationTxt.isUserInteractionEnabled = false
            schoolTxt.isUserInteractionEnabled = false
            degreeImgBtn.isUserInteractionEnabled = false
            qulificationTxt.text = ""
            schoolTxt.text = ""
            degreeImg = nil
            degreeImgBtn.setBackgroundImage(UIImage.init(named: IMAGE.CAMERA_PLACEHOLDER), for: .normal)
        }
    }
    
    @IBAction func clickToContinue(_ sender: Any) {
        self.view.endEditing(true)
        if AppModel.shared.currentUser.picture == "" && imgCompress == nil
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
        else if suburbTxt.text == ""
        {
            displayToast("Please enter suburb")
        }
        else if stateLbl.text == "" || stateLbl.text == "State"
        {
            displayToast("Please select state")
        }
        else if getPoliceCertificate() == "" && policeCheckImg == nil
        {
            displayToast("Please select certificate for police check")
        }
        else if policeCheckImg == nil {
            
            
            displayToast("Police check is mandatory.")

        }
        else if relevantSegment.selectedSegmentIndex == 0 && qulificationTxt.text == ""
        {
            displayToast("Please enter your qulification")
        }
        else if relevantSegment.selectedSegmentIndex == 0 && schoolTxt.text == ""
        {
            displayToast("Please enter your school name")
        }
//        else if relevantSegment.selectedSegmentIndex == 0 && experienceearTxt.text == ""
//        {
//            displayToast("Please enter your experience")
//        }
        else if relevantSegment.selectedSegmentIndex == 0 && AppModel.shared.currentUser.degreeAsset == "" && degreeImg == nil
        {
            displayToast("Please upload your degree")
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
            dict["email"] = AppModel.shared.currentUser.email
            dict["bio"] = AppModel.shared.currentUser.bio
            
            let location : LocationModel = LocationModel.init()
            location.state = stateLbl.text?.uppercased()
            location.suburb = suburbTxt.text?.capitalized
            dict["address"] = location.dictionary()
            AppModel.shared.currentUser.address = location
            
            if relevantSegment.selectedSegmentIndex == 0
            {
                AppModel.shared.currentUser.qualification = qulificationTxt.text
                AppModel.shared.currentUser.school = schoolTxt.text
                dict["qualification"] = AppModel.shared.currentUser.qualification
                dict["school"] = AppModel.shared.currentUser.school
                AppModel.shared.currentUser.hasDegree = true
            }
            else
            {
                AppModel.shared.currentUser.hasDegree = false
            }
            dict["experience"] = experienceearTxt.text
            dict["hasDegree"] = AppModel.shared.currentUser.hasDegree
            var imageData : Data = Data()
            var degreeData : Data = Data()
            var policeData : Data = Data()
            var childrenData : Data = Data()
            
            if imgCompress != nil
            {
                imageData = UIImagePNGRepresentation(imgCompress)!
            }
            if relevantSegment.selectedSegmentIndex == 0 && degreeImg != nil
            {
                degreeData = UIImagePNGRepresentation(degreeImg)!
            }
            if policeCheckImg != nil
            {
                policeData = UIImagePNGRepresentation(policeCheckImg)!
            }
            if childrenCheckImg != nil
            {
                childrenData = UIImagePNGRepresentation(childrenCheckImg)!
            } else  {
                
               // APIManager.sharedInstance.serviceCallToDeleteWWCCInformation()

            }

            
            print(dict)
            APIManager.sharedInstance.serviceCallToUpdateTeacherDetail(dict, degreeData: degreeData, pictureData: imageData, completion: {
                if AppModel.shared.firebaseCurrentUser != nil
                {
                    AppModel.shared.firebaseCurrentUser.name =  AppModel.shared.currentUser.name
                    AppModel.shared.firebaseCurrentUser.picture =  AppModel.shared.currentUser.picture
                    AppDelegate().sharedDelegate().updateCurrentUserData()
                }
                if policeData.count != 0 || childrenData.count != 0
                {
                    APIManager.sharedInstance.serviceCallToUpdateCertificates(policeData, childrenData: childrenData, completion: {
                        displayToast("Profile updated sucessfully")
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                else
                {
                    displayToast("Profile updated sucessfully")
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    func selectedAvailability(dict: [String : [String]]) {
        print(dict)
        availabilityDict = dict
    }
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        if photoSelectionType == PHOTO.USER_IMAGE
        {
            imgCompress = nil
            userProfilePicBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
        }
        else if photoSelectionType == PHOTO.POLICE_IMAGE
        {
            policeCheckImg = nil
            policeCheckBtn.setBackgroundImage(UIImage.init(named: IMAGE.CAMERA_PLACEHOLDER), for: .normal)
        }
        else if photoSelectionType == PHOTO.CHILDREN_IMAGE
        {
            childrenCheckImg = nil
            childrenCheckBtn.setBackgroundImage(UIImage.init(named: IMAGE.CAMERA_PLACEHOLDER), for: .normal)
        }
        else if photoSelectionType == PHOTO.DEGREE_IMAGE
        {
            degreeImg = nil
            degreeImgBtn.setBackgroundImage(UIImage.init(named: IMAGE.CAMERA_PLACEHOLDER), for: .normal)
        }
    }
    
    func onSelectPic(_ img: UIImage) {
        
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
        let deleteButton = UIAlertAction(title: "Delete Photo", style: .default)
        { _ in
            print("Delete")
            self.onRemovePic()
        }
        
        
        actionSheet.addAction(deleteButton)
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
        self.dismiss(animated: true, completion: nil)
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayToast("Your device has no camera")
            
        }
        else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .camera
            self.present(imgPicker, animated: true, completion: {() -> Void in
            })
        }
    }
    
    @objc open func onCaptureImageThroughGallery()
    {
        self.dismiss(animated: true, completion: nil)
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        self.present(imgPicker, animated: true, completion: {() -> Void in
        })
    }
    
    func imagePickerController(_ imgPicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgPicker.dismiss(animated: true, completion: {() -> Void in
        })
        
        let selectedImage: UIImage? = (info["UIImagePickerControllerOriginalImage"] as? UIImage)
        if selectedImage == nil {
            return
        }
        if photoSelectionType == PHOTO.USER_IMAGE
        {
            imgCompress = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            userProfilePicBtn.setBackgroundImage(imgCompress.imageCropped(toFit: userProfilePicBtn.frame.size), for: .normal)
        }
        else if photoSelectionType == PHOTO.POLICE_IMAGE
        {
            policeCheckImg = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            policeCheckBtn.setBackgroundImage(policeCheckImg.imageCropped(toFit: policeCheckBtn.frame.size), for: .normal)
        }
        else if photoSelectionType == PHOTO.CHILDREN_IMAGE
        {
            childrenCheckImg = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            childrenCheckBtn.setBackgroundImage(childrenCheckImg.imageCropped(toFit: childrenCheckBtn.frame.size), for: .normal)
        }
        else if photoSelectionType == PHOTO.DEGREE_IMAGE
        {
            degreeImg = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            degreeImgBtn.setBackgroundImage(degreeImg.imageCropped(toFit: degreeImgBtn.frame.size), for: .normal)
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
