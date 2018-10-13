//
//  TeacherCertificationVC.swift
//  Tutable
//
//  Created by Keyur on 28/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit


class TeacherCertificationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var policeCheckBtn: UIButton!
    @IBOutlet weak var childrenCheckBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!

    var policeCheckImg:UIImage!
    var childrenCheckImg:UIImage!
    var isPoliceCheckImg : Bool = false
    
    var isBackDisplay : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        backBtn.isHidden = !isBackDisplay
        if getPoliceCertificate() != "" && getChildreanCertificate() != ""
        {
            setUserDetail()
        }
        else
        {
            APIManager.sharedInstance.serviceCallToGetCertificate {
                self.setUserDetail()
            }
        }
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        policeCheckBtn.addCornerRadiusOfView(5.0)
        childrenCheckBtn.addCornerRadiusOfView(5.0)
        submitBtn.addCornerRadiusOfView(submitBtn.frame.size.height/2)
    }
    
    func setUserDetail()
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
    
    // MARK: - Button click event
    @IBAction func clickToUploadPoliceCheck(_ sender: Any) {
        isPoliceCheckImg = true
        uploadImage()
    }
    
    @IBAction func clickToPoliceCheckURL(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string : POLICE_CHECK_URL)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func clickToChildrenCheck(_ sender: Any) {
        isPoliceCheckImg = false
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
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSubmit(_ sender: Any) {
//        if getPoliceCertificate() == "" && policeCheckImg == nil
//        {
//            displayToast("Please select certificate for police check")
//        }
//        else if AppModel.shared.currentUser.childrenCert == "" && childrenCheckImg == nil
//        {
//            displayToast("Please select certificate for children check")
//        }
//        else
//        {
            var policeData : Data = Data()
            var childrenData : Data = Data()
            
            if policeCheckImg != nil, let tempData = UIImagePNGRepresentation(policeCheckImg){
                policeData = tempData
            }
            if childrenCheckImg != nil, let tempData = UIImagePNGRepresentation(childrenCheckImg){
                childrenData = tempData
            }
            if policeCheckImg == nil //&& getPoliceCertificate() != ""
            {
                let vc : TeacherFinishVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherFinishVC") as! TeacherFinishVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                APIManager.sharedInstance.serviceCallToUpdateCertificates(policeData, childrenData: childrenData) {
                    let vc : TeacherQulificationVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "TeacherQulificationVC") as! TeacherQulificationVC
                    vc.isBackDisplay = self.isBackDisplay
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        //}
        
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
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        actionSheet.popoverPresentationController?.permittedArrowDirections = []
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
        
        if isPoliceCheckImg
        {
            policeCheckImg = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            policeCheckBtn.setBackgroundImage(policeCheckImg.imageCropped(toFit: policeCheckBtn.frame.size), for: .normal)
        }
        else
        {
            childrenCheckImg = compressImage(selectedImage!, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            childrenCheckBtn.setBackgroundImage(childrenCheckImg.imageCropped(toFit: childrenCheckBtn.frame.size), for: .normal)
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
