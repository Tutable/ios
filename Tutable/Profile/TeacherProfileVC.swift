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
    @IBOutlet weak var qulificationBtn: UIButton!
    @IBOutlet weak var exprienceBtn: UIButton!
    @IBOutlet weak var policeCheckBtn: UIButton!
    @IBOutlet weak var childrenCheckBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
        
        setTeacherDetail()
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
        
        userNameLbl.text = "By " + AppModel.shared.currentUser.name
        if AppModel.shared.currentUser.address.suburb != ""
        {
            userSubTitleLbl.text = AppModel.shared.currentUser.address.suburb
        }
        if AppModel.shared.currentUser.address.state != ""
        {
            if userSubTitleLbl.text != ""
            {
                userSubTitleLbl.text = userSubTitleLbl.text! + " " + AppModel.shared.currentUser.address.state
            }
            else
            {
                userSubTitleLbl.text = AppModel.shared.currentUser.address.state
            }
        }
        
        qulificationBtn.setTitle(AppModel.shared.currentUser.qualification, for: .normal)
        
        aboutUserLbl.text = AppModel.shared.currentUser.bio
        constraintHeightAboutUserLbl.constant = aboutUserLbl.getLableHeight()
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
