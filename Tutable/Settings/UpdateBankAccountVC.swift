//
//  UpdateBankAccountVC.swift
//  Tutable
//
//  Created by Keyur on 21/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class UpdateBankAccountVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var accountNameTxt: UITextField!
    @IBOutlet weak var accountNumberTxt: UITextField!
    @IBOutlet weak var bsbTxt: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let holder : String = AppModel.shared.currentUser.card["holder"] as? String
        {
            accountNameTxt.text = holder
        }
        if let bsb : String = AppModel.shared.currentUser.card["bsb"] as? String
        {
            bsbTxt.text = bsb
            bsbTxt.text = bsbTxt.text?.replacingOccurrences(of: " ", with: "")
        }
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
    }
    
    func setUIDesigning()
    {
        doneBtn.addCornerRadiusOfView(doneBtn.frame.size.height/2)
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToDone(_ sender: Any) {
        self.view.endEditing(true)
        if accountNameTxt.text?.trimmed == ""
        {
            displayToast("Please enter account name")
        }
        else if accountNumberTxt.text?.trimmed == ""
        {
            displayToast("Please enter account number")
        }
        else if bsbTxt.text?.trimmed == ""
        {
            displayToast("Please enter BSB number")
        }
        else
        {
            var finalDict : [String : Any] = [String : Any]()
            var accountDict : [String : Any] = [String : Any]()
            accountDict["accountHolder"] = accountNameTxt.text?.trimmed
            accountDict["accountNumber"] = accountNumberTxt.text?.trimmed
            accountDict["bsb"] = bsbTxt.text?.trimmed
            finalDict["account"] = accountDict
            
            print(finalDict)
            APIManager.sharedInstance.serviceCallToUpdateStripeBankAccount(finalDict, completion: {
                displayToast("Payment details updated successfully")
                self.navigationController?.popViewController(animated: true)
            })
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
