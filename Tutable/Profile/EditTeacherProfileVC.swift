//
//  EditTeacherProfileVC.swift
//  Tutable
//
//  Created by Keyur on 11/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import DropDown

struct PHOTO {
    static var USER_IMAGE = 1
    static var POLICE_IMAGE = 2
    static var CHILDREN_IMAGE = 3
    static var DEGREE_IMAGE = 4
}

class EditTeacherProfileVC: UIViewController, TeacherAvailabilityDelegate, PhotoSelectionDelegate {

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
    @IBOutlet weak var degreeImgBtn: UIButton!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    var selectedDob : Date!
    var _PhotoSelectionVC:PhotoSelectionVC!
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
        
        _PhotoSelectionVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
        
        
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
        
        qulificationTxt.text = AppModel.shared.currentUser.qualification
        schoolTxt.text = AppModel.shared.currentUser.school
        if AppModel.shared.currentUser.degreeAsset != ""
        {
            APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.degreeAsset, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [degreeImgBtn])
        }
    }
    
    func setCertificateImage()
    {
        if getPoliceCertificate() != ""
        {
            APIManager.sharedInstance.serviceCallToGetCertificate(getPoliceCertificate(), placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [policeCheckBtn])
        }
        if getChildreanCertificate() != ""
        {
            APIManager.sharedInstance.serviceCallToGetCertificate(getChildreanCertificate(), placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [childrenCheckBtn])
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
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    @IBAction func clickToUploadPoliceCheck(_ sender: Any) {
        self.view.endEditing(true)
        photoSelectionType = PHOTO.POLICE_IMAGE
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
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
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    @IBAction func clickToUploadDegreeImg(_ sender: Any) {
        self.view.endEditing(true)
        photoSelectionType = PHOTO.DEGREE_IMAGE
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
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
        else if selectedDob == nil
        {
            displayToast("Please select date of birth")
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
        else if relevantSegment.selectedSegmentIndex == 1 && qulificationTxt.text == ""
        {
            displayToast("Please enter your qulification")
        }
        else if relevantSegment.selectedSegmentIndex == 1 && schoolTxt.text == ""
        {
            displayToast("Please enter your school name")
        }
        else if relevantSegment.selectedSegmentIndex == 1 && AppModel.shared.currentUser.degreeAsset == "" && degreeImg == nil
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
            location.state = stateLbl.text
            location.suburb = suburbTxt.text
            dict["address"] = location.dictionary()
            AppModel.shared.currentUser.address = location
            
            if relevantSegment.selectedSegmentIndex == 1
            {
                AppModel.shared.currentUser.qualification = qulificationTxt.text
                AppModel.shared.currentUser.school = schoolTxt.text
                dict["qualification"] = AppModel.shared.currentUser.qualification
                dict["school"] = AppModel.shared.currentUser.school
            }
            
            var imageData : Data = Data()
            var degreeData : Data = Data()
            var policeData : Data = Data()
            var childrenData : Data = Data()
            
            if imgCompress != nil
            {
                imageData = UIImagePNGRepresentation(imgCompress)!
            }
            if relevantSegment.selectedSegmentIndex == 1 && degreeImg != nil
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
            }
            APIManager.sharedInstance.serviceCallToUpdateTeacherDetail(dict, degreeData: degreeData, pictureData: imageData, completion: {
                AppModel.shared.firebaseCurrentUser.name =  AppModel.shared.currentUser.name
                AppModel.shared.firebaseCurrentUser.picture =  AppModel.shared.currentUser.picture
                AppDelegate().sharedDelegate().updateCurrentUserData()
                if policeData.count != 0 || childrenData.count != 0
                {
                    APIManager.sharedInstance.serviceCallToUpdateCertificates(policeData, childrenData: childrenData, completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                else
                {
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
            policeCheckBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
        }
        else if photoSelectionType == PHOTO.CHILDREN_IMAGE
        {
            childrenCheckImg = nil
            childrenCheckBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
        }
        else if photoSelectionType == PHOTO.DEGREE_IMAGE
        {
            degreeImg = nil
            degreeImgBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
        }
    }
    
    func onSelectPic(_ img: UIImage) {
        if photoSelectionType == PHOTO.USER_IMAGE
        {
            imgCompress = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            userProfilePicBtn.setBackgroundImage(imgCompress.imageCropped(toFit: userProfilePicBtn.frame.size), for: .normal)
        }
        else if photoSelectionType == PHOTO.POLICE_IMAGE
        {
            policeCheckImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            policeCheckBtn.setBackgroundImage(policeCheckImg.imageCropped(toFit: policeCheckBtn.frame.size), for: .normal)
        }
        else if photoSelectionType == PHOTO.CHILDREN_IMAGE
        {
            childrenCheckImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            childrenCheckBtn.setBackgroundImage(childrenCheckImg.imageCropped(toFit: childrenCheckBtn.frame.size), for: .normal)
        }
        else if photoSelectionType == PHOTO.DEGREE_IMAGE
        {
            degreeImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
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
