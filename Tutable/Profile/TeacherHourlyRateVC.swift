
//
//  TeacherHourlyRateVC.swift
//  Tutable
//
//  Created by Keyur on 29/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class TeacherHourlyRateVC: UIViewController {

    @IBOutlet weak var priceUnitLbl: UILabel!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var perHourLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        let vc : TeacherFinishVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherFinishVC") as! TeacherFinishVC
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
