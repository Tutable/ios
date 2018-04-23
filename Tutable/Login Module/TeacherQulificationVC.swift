//
//  TeacherQulificationVC.swift
//  Tutable
//
//  Created by Keyur on 29/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class TeacherQulificationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var relevantSegment: UISegmentedControl!
    @IBOutlet weak var qulificationTxt: UITextField!
    @IBOutlet weak var schoolTxt: UITextField!
    @IBOutlet weak var exprienceYearTxt: UITextField!
    @IBOutlet weak var degreeImgBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!

    var degreeImg:UIImage!
    
    var isBackDisplay : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backBtn.isHidden = !isBackDisplay
        relevantSegment.selectedSegmentIndex = 0
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
    
    @IBAction func clickToChangeSegment(_ sender: Any) {
        if relevantSegment.selectedSegmentIndex == 0
        {
            qulificationTxt.isUserInteractionEnabled = true
            schoolTxt.isUserInteractionEnabled = true
            degreeImgBtn.isUserInteractionEnabled = true
            exprienceYearTxt.isUserInteractionEnabled = true
        }
        else
        {
            qulificationTxt.isUserInteractionEnabled = false
            schoolTxt.isUserInteractionEnabled = false
            degreeImgBtn.isUserInteractionEnabled = false
            exprienceYearTxt.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToUploadDegreeImg(_ sender: Any) {
        self.view.endEditing(true)
        uploadImage()
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
            else if exprienceYearTxt.text == ""
            {
                displayToast("Please enter your experience")
            }
            else if AppModel.shared.currentUser.degreeAsset == "" && degreeImg == nil
            {
                displayToast("Please upload your degree")
            }
            else
            {
                AppModel.shared.currentUser.qualification = qulificationTxt.text
                AppModel.shared.currentUser.school = schoolTxt.text
                AppModel.shared.currentUser.experience = Int(exprienceYearTxt.text!)
                let dict : [String  :Any] = ["qualification" : AppModel.shared.currentUser.qualification, "school" : AppModel.shared.currentUser.school, "experience" : AppModel.shared.currentUser.experience]
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
        else
        {
            if isBackDisplay == false
            {
                AppDelegate().sharedDelegate().navigateToDashboard()
            }
            else if self.tabBarController?.tabBar == nil
            {
                let vc : TeacherFinishVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherFinishVC") as! TeacherFinishVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func continueUpdating(_ dict : [String : Any], _ imageData : Data)
    {
        APIManager.sharedInstance.serviceCallToUpdateTeacherDetail(dict, degreeData: imageData, pictureData: Data(), completion: {
            if self.tabBarController?.tabBar == nil
            {
                let vc : TeacherFinishVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherFinishVC") as! TeacherFinishVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
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
        degreeImg = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
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
