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
    @IBOutlet weak var classHeaderView: UIView!
    @IBOutlet weak var classFooterView: UIView!
    
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var bookClassBtn: UIButton!
    @IBOutlet weak var userProfilePicBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userSubTitleLbl: UILabel!
    @IBOutlet weak var classPriceLbl: UILabel!
    @IBOutlet weak var priceUnitLbl: UILabel!
    @IBOutlet weak var studentLevelLbl: UILabel!
    @IBOutlet weak var aboutClassLbl: UILabel!
    @IBOutlet weak var subjectLoveLbl: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var totalReviewLbl: UILabel!
    @IBOutlet weak var moreReviewBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomReviewsTVC", bundle: nil), forCellReuseIdentifier: "CustomReviewsTVC")
        
        tblView.tableHeaderView = classHeaderView
        tblView.tableFooterView = classFooterView
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
        bookClassBtn.addCornerRadiusOfView(bookClassBtn.frame.size.height/2)
        userProfilePicBtn.addCornerRadiusOfView(userProfilePicBtn.frame.size.height/2)
        moreReviewBtn.addCornerRadiusOfView(moreReviewBtn.frame.size.height/2)
        moreReviewBtn.applyBorderOfView(width: 1, borderColor: colorFromHex(hex: COLOR.APP_COLOR))
    }
    
    func setClassDetail()
    {
        
    }
    
    // MARK: - Button click event
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToBookClass(_ sender: Any) {
        
    }
    
    @IBAction func clickToMessage(_ sender: Any) {
        
    }
    
    @IBAction func clickToUserProfilePicture(_ sender: Any) {
        let vc : TeacherDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "TeacherDetailVC") as! TeacherDetailVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToMoreReviews(_ sender: Any) {
        let vc : ReviewListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewListVC") as! ReviewListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomReviewsTVC", for: indexPath) as! CustomReviewsTVC
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
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
