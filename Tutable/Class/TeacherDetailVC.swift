//
//  TeacherDetailVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class TeacherDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constraintHeightTblView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightHeaderView: NSLayoutConstraint!
    @IBOutlet weak var classHeaderView: UIView!
    @IBOutlet weak var classFooterView: UIView!
    @IBOutlet weak var constraintHeightFooterView: NSLayoutConstraint!
    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var userBackgroundImgBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userSubTitleLbl: UILabel!
    @IBOutlet weak var aboutUserLbl: UILabel!
    @IBOutlet weak var constraintHeightAboutUserLbl: NSLayoutConstraint!
    @IBOutlet weak var moreClassesBtn: UIButton!
    @IBOutlet weak var quality1Btn: UIButton!
    @IBOutlet weak var quality2Btn: UIButton!
    @IBOutlet weak var quality3Btn: UIButton!
    @IBOutlet weak var quality4Btn: UIButton!
    @IBOutlet weak var constraintHeightQualityView: NSLayoutConstraint!
    @IBOutlet weak var seeMoreLessBtn: UIButton!
    
    var teacherID : String = ""
    var teacherData : UserModel = UserModel.init()
    var classData : [ClassModel] = [ClassModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomClassesTVC", bundle: nil), forCellReuseIdentifier: "CustomClassesTVC")
        self.constraintHeightTblView.constant = self.tblView.contentSize.height
        seeMoreLessBtn.isHidden = true
        quality1Btn.isHidden = true
        quality2Btn.isHidden = true
        quality3Btn.isHidden = true
        quality4Btn.isHidden = true
        constraintHeightQualityView.constant = 0
        moreClassesBtn.isHidden = true
        constraintHeightFooterView.constant = 0
        getTeacherDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        userProfilePicBtn.addCornerRadiusOfView(userProfilePicBtn.frame.size.height/2)
        moreClassesBtn.addCornerRadiusOfView(moreClassesBtn.frame.size.height/2)
        moreClassesBtn.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
    }
    
    func getTeacherDetail()
    {
        APIManager.sharedInstance.serviceCallToGetTeacehrDetail(teacherID) { (data) in
            self.teacherData = UserModel.init(dict: data)
            self.setTeacherDetail()
        }
    }
     
    func setTeacherDetail()
    {
        APIManager.sharedInstance.serviceCallToGetPhoto(teacherData.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [userProfilePicBtn, userBackgroundImgBtn])

        userNameLbl.text = teacherData.name
        if teacherData.address.suburb != ""
        {
            userSubTitleLbl.text = teacherData.address.suburb.capitalized
        }
        if teacherData.address.state != ""
        {
            if userSubTitleLbl.text != ""
            {
                userSubTitleLbl.text = userSubTitleLbl.text! + ", " + teacherData.address.state.uppercased()
            }
            else
            {
                userSubTitleLbl.text = teacherData.address.state.uppercased()
            }
        }
        
        var arrTemp : [[String : String]] = [[String : String]]()
        
        if teacherData.qualification != ""
        {
            var strDegree : String = teacherData.qualification
            if teacherData.school != ""
            {
                strDegree = strDegree + " from " + teacherData.school
            }
            arrTemp.append(["name" : strDegree, "image" : "qualification_icon"])
        }
        
        if teacherData.experience > 0
        {
            arrTemp.append(["name" : String(teacherData.experience), "image" : "experience_icon"])
        }
        
        let certsDict : [String : Any] = teacherData.certs
        if let police : String = certsDict["policeCertificate"] as? String, police != ""
        {
            arrTemp.append(["name" : "Police check", "image" : "accept"])
        }
        if let children : String = certsDict["childrenCertificate"] as? String, children != ""
        {
            arrTemp.append(["name" : "WWCC", "image" : "accept"])
        }
        
        quality1Btn.isHidden = true
        quality2Btn.isHidden = true
        quality3Btn.isHidden = true
        quality4Btn.isHidden = true
        constraintHeightQualityView.constant = 0
        for i in 0..<arrTemp.count
        {
            if i == 0
            {
                quality1Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality1Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality1Btn.isHidden = false
                constraintHeightQualityView.constant = 40
            }
            else if i == 1
            {
                quality2Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality2Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality2Btn.isHidden = false
            }
            else if i == 2
            {
                quality3Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality3Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality3Btn.isHidden = false
                constraintHeightQualityView.constant = 80
            }
            else if i == 3
            {
                quality4Btn.setImage(UIImage.init(named: arrTemp[i]["image"]!), for: .normal)
                quality4Btn.setTitle(arrTemp[i]["name"], for: .normal)
                quality4Btn.isHidden = false
            }
        }
        aboutUserLbl.numberOfLines = 3
        aboutUserLbl.text = teacherData.bio
        constraintHeightAboutUserLbl.constant = aboutUserLbl.getLableHeight(numberOfLines: 3)
        if constraintHeightAboutUserLbl.constant < 60
        {
            seeMoreLessBtn.isHidden = true
        }
        else
        {
            seeMoreLessBtn.isHidden = false
        }
        updateHeaderViewHeight()
        getClassList()
    }

    func updateHeaderViewHeight()
    {
        classHeaderView.layoutIfNeeded()
        constraintHeightHeaderView.constant = 390 - 25 + constraintHeightAboutUserLbl.constant + constraintHeightQualityView.constant
        constraintHeightTblView.constant = 100 * 2
    }
    
    func getClassList()
    {
        APIManager.sharedInstance.serviceCallToGetClassList("", teacherId: teacherData.id) { (dataArr) in
            self.classData = [ClassModel]()
            for temp in dataArr
            {
                self.classData.append(ClassModel.init(dict: temp))
                if self.classData.count == 2
                {
                    break
                }
            }
            if self.classData.count > 0
            {
                self.tblView.reloadData()
                self.constraintHeightTblView.constant = CGFloat(self.classData.count * 100)
                self.moreClassesBtn.isHidden = false
                self.constraintHeightFooterView.constant = 55
            }
            else
            {
                self.moreClassesBtn.isHidden = true
                self.constraintHeightTblView.constant = 0
                self.moreClassesBtn.isHidden = true
                self.constraintHeightFooterView.constant = 0
            }
        }
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToUserProfilePicBtn(_ sender: Any) {
        
    }
    
    @IBAction func clickToCollapsExpandAboutUserLabel(_ sender: Any) {
        if aboutUserLbl.numberOfLines == 3
        {
            aboutUserLbl.numberOfLines = 0
            seeMoreLessBtn.setTitle("See Less", for: .normal)
        }
        else
        {
            aboutUserLbl.numberOfLines = 3
            seeMoreLessBtn.setTitle("...See More", for: .normal)
        }
        constraintHeightAboutUserLbl.constant = aboutUserLbl.getLableHeight(numberOfLines: aboutUserLbl.numberOfLines)
        updateHeaderViewHeight()
    }
    
    @IBAction func clickToMoreClasses(_ sender: Any) {
        let vc : ClassesListVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "ClassesListVC") as! ClassesListVC
        vc.teacherData = teacherData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomClassesTVC", for: indexPath) as! CustomClassesTVC
        
        let dict : ClassModel = classData[indexPath.row]
        
        APIManager.sharedInstance.serviceCallToGetPhoto(dict.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [cell.imgBtn])
        cell.titleLbl.text = dict.name
        if let avgStars = dict.reviews["avgStars"] as? Double
        {
            cell.starBtn.setTitle(String(avgStars), for: .normal)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : ClassDetailVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "ClassDetailVC") as! ClassDetailVC
        vc.classId = classData[indexPath.row].id
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
