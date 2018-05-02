//
//  HelpAboutUsVC.swift
//  Tutable
//
//  Created by Keyur on 21/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class HelpAboutUsVC: UIViewController {

    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var aboutTxtView: UITextView!
    
    var strTitle : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titlelbl.text = strTitle
        setDataValue()
        aboutTxtView.setContentOffset(CGPoint.zero, animated: false)
        if aboutTxtView.text == ""
        {
            APIManager.sharedInstance.serviceCallToGetHelpAbout()
            delay(5.0, closure: {
                self.setDataValue()
            })
        }
    }

    func setDataValue()
    {
        if strTitle == "HELP"
        {
            aboutTxtView.text = getHelpContent()
        }
        else if strTitle == "ABOUT"
        {
            aboutTxtView.text = getAboutContent()
        }
        else if strTitle == "TEARMS & CONDITIONS"
        {
            aboutTxtView.text = getTearmsConditionContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
