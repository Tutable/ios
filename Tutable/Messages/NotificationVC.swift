//
//  NotificationVC.swift
//  Tutable
//
//  Created by Keyur on 05/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataFound: UILabel!
    
    var arrNotiData : [[String : Any]] = [[String : Any]]()
    var page : Int = 1
    var limit : Int = 10
    var isLoadNextData : Bool = true
    var refreshControl : UIRefreshControl = UIRefreshControl()
    
    // MARK: - Viewcontroller method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomNotificationTVC", bundle: nil), forCellReuseIdentifier: "CustomNotificationTVC")
        tblView.register(UINib(nibName: "CustomAcceptRejectNotiTVC", bundle: nil), forCellReuseIdentifier: "CustomAcceptRejectNotiTVC")
        tblView.backgroundColor = UIColor.clear
        
        refreshControl.tintColor = colorFromHex(hex: COLOR.APP_COLOR)
        refreshControl.addTarget(self, action: #selector(refreshNotificationList), for: .valueChanged)
        
        APIManager.sharedInstance.serviceCallToclearNotificationCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            self.edgesForExtendedLayout = UIRectEdge.bottom
            tabBar.setTabBarHidden(tabBarHidden: true)
        }
        refreshNotificationList()
    }
    
    @objc func refreshNotificationList()
    {
        page = 1
        limit = 10
        isLoadNextData = true
        serviceCallForNotificationList()
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotiData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isStudentLogin()
        {
            return 85
        }
        else
        {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isStudentLogin()
        {
            let cell = tblView.dequeueReusableCell(withIdentifier: "CustomNotificationTVC", for: indexPath) as! CustomNotificationTVC
            
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
        {
            let cell = tblView.dequeueReusableCell(withIdentifier: "CustomAcceptRejectNotiTVC", for: indexPath) as! CustomAcceptRejectNotiTVC
            
            let dict : [String : Any] = arrNotiData[indexPath.row]
            
            var className : String = ""
            if let classData : [String : Any] = dict["class"] as? [String : Any]
            {
                if let temp : String = classData["name"] as? String
                {
                    className = temp
                }
            }
            
            var studentName : String = ""
            if let studentData : [String : Any] = dict["student"] as? [String : Any]
            {
                if let temp : String = studentData["name"] as? String
                {
                    studentName = temp
                }
            }
            className = className.capitalized
            studentName = studentName.capitalized
            
            let noramlText : String = studentName + " requested for " + className
            
            let attributedString = NSMutableAttributedString(string:noramlText)
            let attrs : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : colorFromHex(hex: COLOR.DARK_TEXT)]
            attributedString.addAttributes(attrs, range: (noramlText as NSString).range(of: studentName))
            attributedString.addAttributes(attrs, range: (noramlText as NSString).range(of: className))
            cell.titleLbl.attributedText = attributedString
            
            cell.subTitleLbl.text = ""
            if let time : Double = dict["time"] as? Double
            {
                let startDate : Date = getDateFromTimeStamp(time)
                cell.subTitleLbl.text = getDateStringFromDate(date: startDate, format: "MMM dd, yyyy, hh:mm a")
                
                let endDate : Date = Calendar.current.date(byAdding: .hour, value: 1, to: getDateFromTimeStamp(time))!
                cell.subTitleLbl.text = cell.subTitleLbl.text! + " - " + getDateStringFromDate(date: endDate, format: "hh:mm a")
            }
            
            cell.acceptBtn.tag = indexPath.row
            cell.acceptBtn.addTarget(self, action: #selector(clickToAccept(_:)), for: .touchUpInside)
            cell.rejectBtn.tag = indexPath.row
            cell.rejectBtn.addTarget(self, action: #selector(clickToReject(_:)), for: .touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadNextData && (arrNotiData.count - 1) == indexPath.row
        {
            serviceCallForNotificationList()
        }
    }
    
    // MARK: - Button click event
    @IBAction func clickToAccept(_ sender: UIButton) {
        let dict : [String : Any] = arrNotiData[sender.tag]
        
        if let bookingRef : String = dict["bookingRef"] as? String
        {
            var param : [String : Any] = [String : Any]()
            param["bookingId"] = bookingRef
            param["confirmed"] = true
            APIManager.sharedInstance.serviceCallToBookingAction(param) { (isSuccess) in
                if isSuccess
                {
                    displayToast("Booking request accepted")
                }
            }
        }
    }
    
    @IBAction func clickToReject(_ sender: UIButton) {
        let dict : [String : Any] = arrNotiData[sender.tag]
        
        if let bookingRef : String = dict["bookingRef"] as? String
        {
            var param : [String : Any] = [String : Any]()
            param["bookingId"] = bookingRef
            param["confirmed"] = false
            APIManager.sharedInstance.serviceCallToBookingAction(param) { (isSuccess) in
                if isSuccess
                {
                    displayToast("Booking request rejected")
                }
            }
        }
    }
    
    // MARK: - Service called
    func serviceCallForNotificationList()
    {
        var dict : [String : Any] = [String : Any]()
        dict["page"] = page
        dict["limit"] = limit
        
        APIManager.sharedInstance.serviceCallToGetNotificationList(dict) { (dictArr) in
            if self.page == 1
            {
                self.arrNotiData = dictArr
            }
            else
            {
                self.arrNotiData.append(contentsOf: dictArr)
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
            if self.arrNotiData.count == 0
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
