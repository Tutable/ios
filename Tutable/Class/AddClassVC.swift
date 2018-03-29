//
//  AddClassVC.swift
//  Tutable
//
//  Created by Keyur on 28/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class AddClassVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var classNameTxt: UITextField!
    @IBOutlet weak var classImgBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var stateBtn: UIButton!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var subjectLbl: UITextField!
    @IBOutlet weak var aboutMeLbl: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToUploadClassImg(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToSelectCategory(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToState(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToNext(_ sender: Any) {
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
