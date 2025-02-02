//
//  PastBookingVC.swift
//  Tutable
//
//  Created by Keyur on 03/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class PastBookingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataFound: UILabel!
    
    var arrPastBookingData : [BookingClassModel] = [BookingClassModel]()
    var page : Int = 1
    var limit : Int = 10
    var isLoadNextData : Bool = true
    var refreshControl : UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib.init(nibName: "CustomUpcomingBookingTVC", bundle: nil), forCellReuseIdentifier: "CustomUpcomingBookingTVC")
        tblView.backgroundColor = UIColor.clear
        
        refreshControl.tintColor = colorFromHex(hex: COLOR.APP_COLOR)
        refreshControl.addTarget(self, action: #selector(refreshUpcomingBookingList), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshUpcomingBookingList()
    }
    
    @objc func refreshUpcomingBookingList()
    {
        page = 1
        limit = 10
        isLoadNextData = true
        serviceCallForPastBookingList()
    }
    
    // MARK: - Tableview Delegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPastBookingData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomUpcomingBookingTVC", for: indexPath) as! CustomUpcomingBookingTVC
        
        let dict : BookingClassModel = arrPastBookingData[indexPath.row]
        cell.classNameLbl.text = dict.classDetails.name
        if isStudentLogin() {
            
            cell.userNameLbl.text = getFirstName(name: dict.teacher.name)
            
        } else {
            
            cell.userNameLbl.text = getFirstName(name: dict.student.name)
            
        }
        
        cell.userNameBtn.tag = indexPath.row
        cell.userNameBtn.addTarget(self, action: #selector(clickToUserName(_:)), for: .touchUpInside)
        
        cell.priceLbl.text = setFlotingPriceWithCurrency(dict.classDetails.rate)
        
        if dict.slot.count != 0
        {
            cell.dateTimeLbl.text = AppDelegate().sharedDelegate().getDateTimeValueFromSlot(dict.slot)
        }
        APIManager.sharedInstance.serviceCallToGetPhoto(dict.classDetails.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [cell.imgBtn])
        cell.imgBtn.isUserInteractionEnabled = true
        cell.imgBtn.tag = indexPath.row
        cell.imgBtn.addTarget(self, action: #selector(clickToReviewBtn(_:)), for: .touchUpInside)
        
        if isStudentLogin()
        {
            if let stars : Double = dict.review["stars"] as? Double
            {
                cell.starView.rating = stars
            }
            else
            {
                cell.starBtn.tag = indexPath.row
                cell.starBtn.addTarget(self, action: #selector(clickToReviewBtn(_:)), for: .touchUpInside)
            }
            
            cell.starBtn.isHidden = false
            cell.starView.isHidden = false
            cell.constraintWidthStarView.constant = 130
        }
        else
        {
            cell.starBtn.isHidden = true
            cell.starView.isHidden = true
        }
        
        cell.chatBtn.isHidden = true
        cell.cancelBtn.isHidden = true
        cell.setCellDesign()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadNextData && (arrPastBookingData.count - 1) == indexPath.row
        {
            serviceCallForPastBookingList()
        }
    }
    
    @IBAction func clickToReviewBtn(_ sender: UIButton) {
        if isStudentLogin()
        {
            if let v = arrPastBookingData[sender.tag].review {
                
                if let avgRating = v["avgStars"] as? Double , avgRating > 0.0 {
                    
                    
                } else {
                    
                    let vc : AddRateReviewVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "AddRateReviewVC") as! AddRateReviewVC
                    vc.bookClassData = arrPastBookingData[sender.tag]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                
                let vc : AddRateReviewVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "AddRateReviewVC") as! AddRateReviewVC
                vc.bookClassData = arrPastBookingData[sender.tag]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func clickToUserName(_ sender: UIButton) {
        if isStudentLogin() {
            let vc : TeacherDetailVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "TeacherDetailVC") as! TeacherDetailVC
            vc.teacherID = arrPastBookingData[sender.tag].teacher.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func serviceCallForPastBookingList()
    {
        var dict : [String : Any] = [String : Any]()
        if isStudentLogin()
        {
            dict["studentId"] = AppModel.shared.currentUser.id
        }
        else
        {
            dict["teacherId"] = AppModel.shared.currentUser.id
        }
        dict["bookingType"] = 2
        dict["page"] = page
        dict["limit"] = limit
        
        APIManager.sharedInstance.serviceCallToGetBookingList(dict) { (dictArr) in
            print(dictArr)
            if self.page == 1
            {
                self.arrPastBookingData = [BookingClassModel]()
                for temp in dictArr
                {
                    self.arrPastBookingData.append(BookingClassModel.init(dict: temp))
                }
            }
            else
            {
                for temp in dictArr
                {
                    self.arrPastBookingData.append(BookingClassModel.init(dict: temp))
                }
            }
            self.tblView.reloadData()
            if dictArr.count < 10
            {
                self.isLoadNextData = false
            }
            else
            {
                self.page = self.page + 1
            }
            if self.arrPastBookingData.count == 0
            {
                self.noDataFound.isHidden = false
            }
            else
            {
                self.noDataFound.isHidden = true
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
