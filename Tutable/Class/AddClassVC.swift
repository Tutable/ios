//
//  AddClassVC.swift
//  Tutable
//
//  Created by Keyur on 28/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class AddClassVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PhotoSelectionDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var classNameTxt: UITextField!
    @IBOutlet weak var classImgBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var stateBtn: UIButton!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var subjectLbl: UITextField!
    @IBOutlet weak var aboutMeLbl: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet var categoryContainerView: UIView!
    @IBOutlet weak var categoryPopupView: UIView!
    @IBOutlet weak var categoryTblView: UITableView!
    @IBOutlet weak var constraintHeightCategoryPopup: NSLayoutConstraint!
    
    var _PhotoSelectionVC:PhotoSelectionVC!
    var classImg:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _PhotoSelectionVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSelectionVC") as! PhotoSelectionVC
        _PhotoSelectionVC.delegate = self
        self.addChildViewController(_PhotoSelectionVC)
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        classImgBtn.addCornerRadiusOfView(5.0)
        stateBtn.addCornerRadiusOfView(5.0)
        stateBtn.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.LIGHT_GRAY))
        nextBtn.addCornerRadiusOfView(nextBtn.frame.size.height/2)
        categoryPopupView.addCornerRadiusOfView(10.0)
        
        categoryTblView.register(UINib.init(nibName: "CustomTimeSlotTVC", bundle: nil), forCellReuseIdentifier: "CustomTimeSlotTVC")
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
        categoryTblView.reloadData()
        constraintHeightCategoryPopup.constant = categoryTblView.contentSize.height
        if constraintHeightCategoryPopup.constant > (UIScreen.main.bounds.size.height - 100)
        {
            constraintHeightCategoryPopup.constant = (UIScreen.main.bounds.size.height - 100)
        }
        displaySubViewtoParentView(self.view, subview: categoryContainerView)
    }
    
    @IBAction func clickToCloseCategory(_ sender: Any) {
        categoryContainerView.removeFromSuperview()
    }
    
    @IBAction func clickToState(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToNext(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomTimeSlotTVC = categoryTblView.dequeueReusableCell(withIdentifier: "CustomTimeSlotTVC", for: indexPath) as! CustomTimeSlotTVC
        cell.selectionBtn.setImage(UIImage.init(named: "check_circle_off"), for: .normal)
        cell.selectionBtn.setImage(UIImage.init(named: "check_circle_on"), for: .selected)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //MARK:- PhotoSelectionDelegate
    func onRemovePic() {
        classImg = nil
        classImgBtn.setBackgroundImage(UIImage.init(named: IMAGE.USER_PLACEHOLDER), for: .normal)
    }
    
    func onSelectPic(_ img: UIImage) {
        classImg = compressImage(img, to: CGSize(width: CGFloat(CONSTANT.DP_IMAGE_WIDTH), height: CGFloat(CONSTANT.DP_IMAGE_HEIGHT)))
        classImgBtn.setBackgroundImage(classImg, for: .normal)
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
