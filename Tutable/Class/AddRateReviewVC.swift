//
//  AddRateReviewVC.swift
//  Tutable
//
//  Created by Keyur on 04/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class AddRateReviewVC: UIViewController {

    @IBOutlet weak var classImgBtn: UIButton!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var userPicBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var starView: FloatRatingView!
    @IBOutlet weak var reviewTxtView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setUIDesigning()
    {
        
    }
    
    
    @IBAction func clickToSubmit(_ sender: Any) {
        
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        
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
