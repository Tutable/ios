//
//  EditTeacherProfileVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import DropDown

class EditTeacherProfileVC: UIViewController, TeacherAvailabilityDelegate, PhotoSelectionDelegate {

    @IBOutlet weak var userProfilePicBtn: UIButton!
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
    var _PhotoSelectionVC:PhotoSelectionVC!
    var _imgCompress:UIImage!
    
    var availabilityDict : [String : [String]] = [String : [String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _PhotoSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
        
        setUserDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
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
    }
    
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToUploadProfilePic(_ sender: Any) {
        self.view.endEditing(true)
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
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
        let vc : TeacherAvailabilityVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherAvailabilityVC") as! TeacherAvailabilityVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToSelectState(_ sender: Any) {
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
        AppModel.shared.currentUser.suburb = suburbTxt.text
        AppModel.shared.currentUser.state = stateLbl.text
        if let imageData = UIImagePNGRepresentation(_imgCompress){
            APIManager.sharedInstance.serviceCallToUpdateUserDetail(AppModel.shared.currentUser.dictionary(), degreeData: Data(), pictureData: imageData, completion: {
                let vc : TeacherCertificationVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherCertificationVC") as! TeacherCertificationVC
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        else{
            displayToast("Getting error in profile pic, please select another one.")
            return
        }
    }
    
    func selectedAvailability(dict: [String : [String]]) {
        print(dict)
        availabilityDict = dict
    }
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        _imgCompress = nil
        userProfilePicBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
    }
    
    func onSelectPic(_ img: UIImage) {
        _imgCompress = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
        userProfilePicBtn.setBackgroundImage(_imgCompress, for: .normal)
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
