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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _PhotoSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToSelectState(_ sender: Any) {
        let stateArr : [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]
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
        let vc : TeacherCertificationVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherCertificationVC") as! TeacherCertificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func selectedAvailability(dict: [String : [String]]) {
        print(dict)
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
