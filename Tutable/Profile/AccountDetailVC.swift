//
//  AccountDetailVC.swift
//  Tutable
//
//  Created by Keyur on 29/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class AccountDetailVC: UIViewController {

    @IBOutlet weak var accountNameTxt: UITextField!
    @IBOutlet weak var accountNumberTxt: UITextField!
    @IBOutlet weak var bsbTxt: UITextField!
    @IBOutlet weak var abnTxt: UITextField!
    @IBOutlet weak var termsConditionBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        doneBtn.addCornerRadiusOfView(doneBtn.frame.size.height/2)
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToTermsCondition(_ sender: Any) {
        self.view.endEditing(true)
        termsConditionBtn.isSelected = !termsConditionBtn.isSelected
    }
    
    @IBAction func clickToDone(_ sender: Any) {
        self.view.endEditing(true)
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
