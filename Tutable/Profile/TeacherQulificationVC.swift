//
//  TeacherQulificationVC.swift
//  Tutable
//
//  Created by Keyur on 29/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class TeacherQulificationVC: UIViewController, PhotoSelectionDelegate {

    @IBOutlet weak var relevantSegment: UISegmentedControl!
    @IBOutlet weak var qulificationTxt: UITextField!
    @IBOutlet weak var schoolTxt: UITextField!
    @IBOutlet weak var degreeImgBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!

    var _PhotoSelectionVC:PhotoSelectionVC!
    var degreeImg:UIImage!
    
    var isBackDisplay : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _PhotoSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
        
        backBtn.isHidden = !isBackDisplay
        
        setUserDetail()
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        degreeImgBtn.addCornerRadiusOfView(5.0)
        nextBtn.addCornerRadiusOfView(nextBtn.frame.size.height/2)
    }
    
    func setUserDetail()
    {
        if AppModel.shared.currentUser == nil
        {
            return
        }
        qulificationTxt.text = AppModel.shared.currentUser.qualification
        schoolTxt.text = AppModel.shared.currentUser.school
        if AppModel.shared.currentUser.degreeAsset != ""
        {
            APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.degreeAsset, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [degreeImgBtn])
        }
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToUploadDegreeImg(_ sender: Any) {
        self.view.endEditing(true)
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    @IBAction func clickToNext(_ sender: Any) {
        self.view.endEditing(true)
        if relevantSegment.selectedSegmentIndex == 0
        {
            if qulificationTxt.text == ""
            {
                displayToast("Please enter your qulification")
            }
            else if schoolTxt.text == ""
            {
                displayToast("Please enter your school name")
            }
            else if AppModel.shared.currentUser.degreeAsset == "" && degreeImg == nil
            {
                displayToast("Please upload your degree")
            }
            else
            {
                AppModel.shared.currentUser.qualification = qulificationTxt.text
                AppModel.shared.currentUser.school = schoolTxt.text
                let dict : [String  :Any] = ["qualification" : AppModel.shared.currentUser.qualification, "school" : AppModel.shared.currentUser.school]
                print(dict)
                if degreeImg == nil
                {
                    continueUpdating(dict, Data())
                }
                else if let imageData = UIImagePNGRepresentation(degreeImg){
                    continueUpdating(dict, imageData)
                }
                else{
                    displayToast("Getting error in profile pic, please select another one.")
                    return
                }
            }
        }
    }
    
    func continueUpdating(_ dict : [String : Any], _ imageData : Data)
    {
        APIManager.sharedInstance.serviceCallToUpdateTeacherDetail(dict, degreeData: imageData, pictureData: Data(), completion: {
            let vc : TeacherFinishVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherFinishVC") as! TeacherFinishVC
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        degreeImg = nil
        degreeImgBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
    }
    
    func onSelectPic(_ img: UIImage) {
        degreeImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
        degreeImgBtn.setBackgroundImage(degreeImg.imageCropped(toFit: degreeImgBtn.frame.size), for: .normal)
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
