//
//  AddRateReviewVC.swift
//  Tutable
//
//  Created by Keyur on 04/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class AddRateReviewVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var classDetailView: UIView!
    @IBOutlet weak var classImgBtn: UIButton!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var userPicBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    @IBOutlet weak var starView: FloatRatingView!
    @IBOutlet weak var reviewTxtView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    var bookClassData : BookingClassModel!
    
    var placeHolder : String = "Tell us more(Optional)"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUIDesigning()
    }

    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
    }
    
    func setUIDesigning()
    {
        classDetailView.addCornerRadiusOfView(10.0)
        userPicBtn.addCircularRadiusOfView()
        submitBtn.addCornerRadiusOfView(submitBtn.frame.size.height/2)
        
        reviewTxtView.text = placeHolder
        reviewTxtView.textColor = UIColor.lightGray
        reviewTxtView.addCornerRadiusOfView(5.0)
        reviewTxtView.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.LIGHT_GRAY))
        starView.type = .wholeRatings
        starView.editable = true
        setClassDetail()
    }
    
    func setClassDetail()
    {
        
        APIManager.sharedInstance.serviceCallToGetPhoto(bookClassData.classDetails.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [classImgBtn])
        
        classNameLbl.text = bookClassData.classDetails.name
        APIManager.sharedInstance.serviceCallToGetPhoto(bookClassData.teacher.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [userPicBtn])
        userNameLbl.text = bookClassData.teacher.name
        dateTimeLbl.text = AppDelegate().sharedDelegate().getDateTimeValueFromSlot(bookClassData.slot)
        priceLbl.text = setFlotingPriceWithCurrency(bookClassData.classDetails.rate)
        
    }
    
    
    @IBAction func clickToSubmit(_ sender: Any) {
        if starView.rating == 0.0
        {
            displayToast("Please give some rate.")
        }
        else
        {
            var params : [String : Any] = [String : Any]()
            params["ref"] = bookClassData.classDetails.id
            params["bookingReference"] = bookClassData.id
            params["stars"] = starView.rating
            if reviewTxtView.text != placeHolder
            {
                params["review"] = reviewTxtView.text
            }
            
            APIManager.sharedInstance.serviceCallToAddReview(params, completion: { (isDone) in
                if isDone
                {
                    displayToast("Review added successfully.")
                    self.clickToBack(self)
                }
            })
        }
        
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray
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
