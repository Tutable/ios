//
//  StudentProfileVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class StudentProfileVC: UIViewController {

    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        userProfilePicBtn.addCircularRadiusOfView()
        APIManager.sharedInstance.serviceCallToGetPhoto(AppModel.shared.currentUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [userProfilePicBtn])
        userNameLbl.text = ""
        subTitleLbl.text = ""
        userNameLbl.text = AppModel.shared.currentUser.name.uppercased()
        if isStudentLogin()
        {
            subTitleLbl.text = AppModel.shared.currentUser.address.location
        }
        else
        {
            if AppModel.shared.currentUser.address.suburb != ""
            {
                subTitleLbl.text = AppModel.shared.currentUser.address.suburb.capitalized
            }
            if AppModel.shared.currentUser.address.state != ""
            {
                if subTitleLbl.text == ""
                {
                    subTitleLbl.text = AppModel.shared.currentUser.address.state.uppercased()
                }
                else
                {
                    subTitleLbl.text = subTitleLbl.text! + ", " + AppModel.shared.currentUser.address.state.uppercased()
                }
            }
        }
        subTitleLbl.text = subTitleLbl.text?.uppercased()
    }
    
    
    @IBAction func clickToEdit(_ sender: Any) {
            let vc : EditStudentProfileVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "EditStudentProfileVC") as! EditStudentProfileVC
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
