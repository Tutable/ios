//
//  TeacherProfileVC.swift
//  Tutable
//
//  Created by Keyur on 12/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class TeacherProfileVC: UIViewController {

    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var userBackgroundImgBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userSubTitleLbl: UILabel!
    @IBOutlet weak var aboutUserLbl: UILabel!
    @IBOutlet weak var constraintHeightAboutUserLbl: NSLayoutConstraint!
    
    @IBOutlet weak var quality1Btn: UIButton!
    @IBOutlet weak var quality2Btn: UIButton!
    @IBOutlet weak var quality3Btn: UIButton!
    @IBOutlet weak var quality4Btn: UIButton!
    @IBOutlet weak var constraintHeightQualityView: NSLayoutConstraint!
    @IBOutlet weak var seeMoreLessBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        quality1Btn.isHidden = true
        quality2Btn.isHidden = true
        quality3Btn.isHidden = true
        quality4Btn.isHidden = true
        constraintHeightQualityView.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
        
        delay(0.5) {
            self.setTeacherDetail()
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        userProfilePicBtn.addCornerRadiusOfView(userProfilePicBtn.frame.size.height/2)
    }
    
    func setTeacherDetail()
    {
        
        APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [userProfilePicBtn, userBackgroundImgBtn])
        
        userNameLbl.text = AppModel.shared.currentUser.name
        if AppModel.shared.currentUser.address.suburb != ""
        {
            userSubTitleLbl.text = AppModel.shared.currentUser.address.suburb.capitalized
        }
        if AppModel.shared.currentUser.address.state != ""
        {
            if userSubTitleLbl.text != ""
            {
                userSubTitleLbl.text = userSubTitleLbl.text! + ", " + AppModel.shared.currentUser.address.state.uppercased()
            }
            else
            {
                userSubTitleLbl.text = AppModel.shared.currentUser.address.state.uppercased()
            }
        }
        
        var arrTemp : [[String : String]] = [[String : String]]()
        
        if AppModel.shared.currentUser.qualification != ""
        {
            var strDegree : String = AppModel.shared.currentUser.qualification
            if AppModel.shared.currentUser.school != ""
            {
                strDegree = strDegree + " from " + AppModel.shared.currentUser.school
            }
            arrTemp.append(["name" : strDegree, "image" : "qualification_icon"])
        }
        if AppModel.shared.currentUser.experience > 0
        {
            var exprince : String = String(AppModel.shared.currentUser.experience)
            if AppModel.shared.currentUser.experience > 1
            {
                exprince = exprince + " years experience"
            }
            else
            {
                exprince = exprince + " year experience"
            }
            arrTemp.append(["name" : exprince, "image" : "experience_icon"])
        }
        
        let certsDict : [String : Any] = AppModel.shared.currentUser.certs
        if let police : String = certsDict["policeCertificate"] as? String, police != ""
        {
            arrTemp.append(["name" : "Police check", "image" : "accept"])
        }
        if let children : String = certsDict["childrenCertificate"] as? String, children != ""
        {
            arrTemp.append(["name" : "WWCC", "image" : "accept"])
        }
        
        quality1Btn.isHidden = true
        quality2Btn.isHidden = true
        quality3Btn.isHidden = true
        quality4Btn.isHidden = true
        constraintHeightQualityView.constant = 0
        for i in 0..<arrTemp.count
        {
            if i == 0
            {
                quality1Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality1Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality1Btn.isHidden = false
                constraintHeightQualityView.constant = 40
            }
            else if i == 1
            {
                quality2Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality2Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality2Btn.isHidden = false
            }
            else if i == 2
            {
                quality3Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality3Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality3Btn.isHidden = false
                constraintHeightQualityView.constant = 80
            }
            else if i == 3
            {
                quality4Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality4Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality4Btn.isHidden = false
            }
        }
        aboutUserLbl.numberOfLines = 3
        aboutUserLbl.text = AppModel.shared.currentUser.bio
        constraintHeightAboutUserLbl.constant = aboutUserLbl.getLableHeight(numberOfLines: 3)
        if constraintHeightAboutUserLbl.constant < 60
        {
            seeMoreLessBtn.isHidden = true
        }
        else
        {
            seeMoreLessBtn.isHidden = false
        }
    }
    
    @IBAction func clickToCollapsExpandAboutUserLabel(_ sender: Any) {
        if aboutUserLbl.numberOfLines == 3
        {
            aboutUserLbl.numberOfLines = 0
            seeMoreLessBtn.setTitle("See Less", for: .normal)
        }
        else
        {
            aboutUserLbl.numberOfLines = 3
            seeMoreLessBtn.setTitle("...See More", for: .normal)
        }
        constraintHeightAboutUserLbl.constant = aboutUserLbl.getLableHeight(numberOfLines: aboutUserLbl.numberOfLines)
    }
    
    @IBAction func clickToEditBtn(_ sender: Any) {
        let vc : EditTeacherProfileVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "EditTeacherProfileVC") as! EditTeacherProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
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
