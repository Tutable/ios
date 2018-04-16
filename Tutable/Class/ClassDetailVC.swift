//
//  ClassDetailVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class ClassDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constraintHeightTblView: NSLayoutConstraint!
    @IBOutlet weak var classHeaderView: UIView!
    @IBOutlet weak var constraintHeightClassHeaderView: NSLayoutConstraint!
    @IBOutlet weak var classFooterView: UIView!
    @IBOutlet weak var constraintHeightFooterView: NSLayoutConstraint!
    
    @IBOutlet weak var editClassBtn: UIButton!
    @IBOutlet weak var classImg: UIImageView!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var bookClassBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userSubTitleLbl: UILabel!
    @IBOutlet weak var classPriceLbl: UILabel!
    @IBOutlet weak var priceUnitLbl: UILabel!
    @IBOutlet weak var studentLevelLbl: UILabel!
    @IBOutlet weak var subjectLoveLbl: UILabel!
    @IBOutlet weak var constraintHeightSubjectLoveLbl: NSLayoutConstraint!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var totalReviewLbl: UILabel!
    @IBOutlet weak var moreReviewBtn: UIButton!
    
    var classId : String = ""
    var classData : ClassModel = ClassModel()
    var reviewArr : [[String : Any]] = [[String : Any]]()
    var teacherData : UserModel = UserModel()
    var reviewData : [[String : Any]] = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomReviewsTVC", bundle: nil), forCellReuseIdentifier: "CustomReviewsTVC")
        self.constraintHeightFooterView.constant = 0
        self.classFooterView.isHidden = true
        setUIDesigning()
    }

    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
        if isStudentLogin()
        {
            bookClassBtn.isHidden = false
            chatBtn.isHidden = false
            editClassBtn.isHidden = true
        }
        else
        {
            bookClassBtn.isHidden = true
            chatBtn.isHidden = true
            editClassBtn.isHidden = false
        }
        getClassDetail()
    }
    
    func setUIDesigning()
    {
        bookClassBtn.addCornerRadiusOfView(bookClassBtn.frame.size.height/2)
        userProfilePicBtn.addCornerRadiusOfView(userProfilePicBtn.frame.size.height/2)
        moreReviewBtn.addCornerRadiusOfView(moreReviewBtn.frame.size.height/2)
        moreReviewBtn.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
    }
    
    func getClassDetail()
    {
        APIManager.sharedInstance.serviceCallToGetClassDetail(classId) { (dictData) in
            self.classData = ClassModel.init(dict: dictData)
            self.setClassDetail()
            self.getTeacherDetail()
            self.getReviewsList()
        }
    }
    
    func getTeacherDetail()
    {
        APIManager.sharedInstance.serviceCallToGetTeacehrDetail(classData.teacher.id) { (dict) in
            self.teacherData = UserModel.init(dict: dict)
        }
    }
    
    func setClassDetail()
    {
        if !isStudentLogin() && classData.teacher.id == AppModel.shared.currentUser.id
        {
            editClassBtn.isHidden = false
        }
        else
        {
            editClassBtn.isHidden = true
        }
        let url : String = BASE_URL + classData.payload!
        classImg.sd_setImage(with: URL(string : url)) { (image, error, caheType, url) in
            if error == nil
            {
                self.classImg.image = image
            }
            else
            {
                self.classImg.image = UIImage.init(named: IMAGE.CAMERA_PLACEHOLDER)
            }
        }
        
        classNameLbl.text = classData.name
        APIManager.sharedInstance.serviceCallToGetPhoto(classData.teacher.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [userProfilePicBtn])
        userNameLbl.text = classData.teacher.name
        if classData.teacher.address.suburb != ""
        {
            userSubTitleLbl.text = classData.teacher.address.suburb.capitalized
        }
        if classData.teacher.address.state != ""
        {
            if userSubTitleLbl.text != ""
            {
                userSubTitleLbl.text = userSubTitleLbl.text! + " " + classData.teacher.address.state.uppercased()
            }
            else
            {
                userSubTitleLbl.text = classData.teacher.address.state.uppercased()
            }
        }
        classPriceLbl.text = setFlotingPrice(classData.rate)
        studentLevelLbl.text = classLevelArr[classData.level-1]
        subjectLoveLbl.text = classData.bio
        constraintHeightSubjectLoveLbl.constant = subjectLoveLbl.getLableHeight()
        
        if let reviewDict : [String : Any] = classData.reviews, reviewDict.count != 0
        {
            if let avgStars : Int = reviewDict["avgStars"] as? Int
            {
                starBtn.setTitle(String(avgStars), for: .normal)
            }
            if let count : Int = reviewDict["count"] as? Int
            {
                totalReviewLbl.text = String(count) + ((count == 1) ? " review" : " reviews")
            }
        }
        
        classHeaderView.layoutSubviews()
        classHeaderView.layoutIfNeeded()
        classFooterView.layoutIfNeeded()
        
        delay(0.5) {
            self.constraintHeightClassHeaderView.constant = 529 - 25 + self.constraintHeightSubjectLoveLbl.constant
            var newFrame : CGRect = self.classHeaderView.frame
            newFrame.size.height = self.constraintHeightClassHeaderView.constant
            self.classHeaderView.frame = newFrame
            self.tblView.reloadData()
            self.constraintHeightTblView.constant = CGFloat(90 * self.reviewArr.count)
        }
    }
    
    // MARK: - Button click event
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToBookClass(_ sender: Any) {
        let vc : ClassBookingRequestVC = self.storyboard?.instantiateViewController(withIdentifier: "ClassBookingRequestVC") as! ClassBookingRequestVC
        vc.teacherData = teacherData
        vc.classData = classData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToEditClass(_ sender: Any) {
        let vc : AddClassVC = self.storyboard?.instantiateViewController(withIdentifier: "AddClassVC") as! AddClassVC
        vc.classData = classData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToMessage(_ sender: Any) {
        let receiver : FirebaseUserModel = FirebaseUserModel.init(dict: classData.teacher.dictionary())
        AppDelegate().sharedDelegate().onChannelTap(connectUser: receiver)
    }
    
    @IBAction func clickToUserProfilePicture(_ sender: Any) {
        let vc : TeacherDetailVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "TeacherDetailVC") as! TeacherDetailVC
        vc.teacherID = classData.teacher.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToAddReview(_ sender: Any) {
        
    }
    
    @IBAction func clickToMoreReviews(_ sender: Any) {
        let vc : ReviewListVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "ReviewListVC") as! ReviewListVC
        vc.classData = classData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Tableview Delegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewArr.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomReviewsTVC", for: indexPath) as! CustomReviewsTVC
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func getReviewsList()
    {
        APIManager.sharedInstance.serviceCallToGetReviewList(classData.id) { (dictArr) in
            self.reviewData = dictArr
            self.tblView.reloadData()
            if self.reviewData.count > 0
            {
                self.constraintHeightFooterView.constant = 55
                self.classFooterView.isHidden = false
            }
            else
            {
                self.constraintHeightFooterView.constant = 0
                self.classFooterView.isHidden = true
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
