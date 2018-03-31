//
//  TeacherCertificationVC.swift
//  Tutable
//
//  Created by Keyur on 28/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class TeacherCertificationVC: UIViewController, PhotoSelectionDelegate {

    @IBOutlet weak var policeCheckBtn: UIButton!
    @IBOutlet weak var childrenCheckBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    var _PhotoSelectionVC:PhotoSelectionVC!
    var policeCheckImg:UIImage!
    var childrenCheckImg:UIImage!
    var isPoliceCheckImg : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        _PhotoSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        policeCheckBtn.addCornerRadiusOfView(5.0)
        childrenCheckBtn.addCornerRadiusOfView(5.0)
        submitBtn.addCornerRadiusOfView(submitBtn.frame.size.height/2)
        
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
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    @IBAction func clickToPoliceCheckURL(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string : "https://npcoapr.police.nsw.gov.au/aspx/dataentry/Introduction.aspx")!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func clickToChildrenCheck(_ sender: Any) {
        isPoliceCheckImg = false
        self.view.addSubview(_PhotoSelectionVC.view)
        displaySubViewWithScaleOutAnim(_PhotoSelectionVC.view)
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSubmit(_ sender: Any) {
        
        if AppModel.shared.currentUser.policeCert == "" && policeCheckImg == nil
        {
            displayToast("Please select certificate for police check")
        }
        else if AppModel.shared.currentUser.childrenCert == "" && childrenCheckImg == nil
        {
            displayToast("Please select certificate for children check")
        }
        else
        {
            var policeData : Data = Data()
            var childrenData : Data = Data()
            
            if let tempData = UIImagePNGRepresentation(policeCheckImg){
                policeData = tempData
            }
            if let tempData = UIImagePNGRepresentation(childrenCheckImg){
                childrenData = tempData
            }
            if policeCheckImg == nil && childrenCheckImg == nil
            {
                let vc : TeacherFinishVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherFinishVC") as! TeacherFinishVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                APIManager.sharedInstance.serviceCallToUpdateCertificates(policeData, childrenData: childrenData) {
                    let vc : TeacherFinishVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherFinishVC") as! TeacherFinishVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        if isPoliceCheckImg
        {
            policeCheckImg = nil
            policeCheckBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
        }
        else
        {
            childrenCheckImg = nil
            childrenCheckBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
        }
        
    }
    
    func onSelectPic(_ img: UIImage) {
        if isPoliceCheckImg
        {
            policeCheckImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
            policeCheckBtn.setBackgroundImage(policeCheckImg.imageCropped(toFit: policeCheckBtn.frame.size), for: .normal)
        }
        else
        {
            childrenCheckImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
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
