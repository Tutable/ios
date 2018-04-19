
//
//  ClassHourlyRateVC.swift
//  Tutable
//
//  Created by Keyur on 29/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class ClassHourlyRateVC: UIViewController {

    @IBOutlet weak var priceUnitLbl: UILabel!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var perHourLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    var classImg : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if AppModel.shared.currentClass.rate != 0
        {
            priceTxt.text = setFlotingPrice(AppModel.shared.currentClass.rate)
        }
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        priceTxt.addCornerRadiusOfView(5.0)
        priceTxt.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
        priceTxt.addPadding(padding: 5.0)
        submitBtn.addCornerRadiusOfView(submitBtn.frame.size.height/2)
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToSubmit(_ sender: Any) {
        self.view.endEditing(true)
        AppModel.shared.currentClass.rate = Float(priceTxt.text!)
        if AppModel.shared.currentClass.id == ""
        {
            if let imageData = UIImagePNGRepresentation(classImg){
                APIManager.sharedInstance.serviceCallToCreateClass(imageData, completion: {
                    if self.tabBarController == nil
                    {
                        AppDelegate().sharedDelegate().navigateToDashboard()
                    }
                    else
                    {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                })
            }
        }
        else
        {
            if classImg == nil
            {
                continueUpdating(Data())
            }
            else
            {
                if let imageData = UIImagePNGRepresentation(classImg){
                    self.continueUpdating(imageData)
                }
            }
        }
    }
    
    func continueUpdating(_ imageData : Data)
    {
        APIManager.sharedInstance.serviceCallToUpdateClass(imageData) {
            displayToast("Class update successfully.")
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: ClassDetailVC.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
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
