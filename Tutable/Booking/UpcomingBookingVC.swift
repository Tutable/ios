//
//  UpcomingBookingVC.swift
//  Tutable
//
//  Created by Keyur on 03/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class UpcomingBookingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var cancelContainerView: UIView!
    @IBOutlet weak var cancelPopupView: UIView!
    @IBOutlet weak var cancelNoBtn: UIButton!
    @IBOutlet weak var cancelYesBtn: UIButton!
    @IBOutlet weak var noDataFound: UILabel!
    
    @IBOutlet weak var popupTitleLbl: UILabel!
    @IBOutlet weak var popupSubTitleLbl: UILabel!
    @IBOutlet weak var constraintHeightPopupSubTitleLbl: NSLayoutConstraint!
    
    var arrUpcomingBookingData : [BookingClassModel] = [BookingClassModel]()
    var page : Int = 1
    var limit : Int = 10
    var isLoadNextData : Bool = true
    var refreshControl : UIRefreshControl = UIRefreshControl()
    var selectedBooking : BookingClassModel = BookingClassModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib.init(nibName: "CustomUpcomingBookingTVC", bundle: nil), forCellReuseIdentifier: "CustomUpcomingBookingTVC")
        tblView.backgroundColor = UIColor.clear
        
        refreshControl.tintColor = colorFromHex(hex: COLOR.APP_COLOR)
        refreshControl.addTarget(self, action: #selector(refreshUpcomingBookingList), for: .valueChanged)
        
        if isStudentLogin()
        {
            popupSubTitleLbl.isHidden = false
            constraintHeightPopupSubTitleLbl.constant = 50
        }
        else
        {
            popupSubTitleLbl.isHidden = true
            constraintHeightPopupSubTitleLbl.constant = 0
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshUpcomingBookingList()
    }
    
    @objc func refreshUpcomingBookingList()
    {
        page = 1
        limit = 10
        isLoadNextData = true
        serviceCallForUpcomingBookingList()
    }
    

    // MARK: - Tableview Delegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUpcomingBookingData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomUpcomingBookingTVC", for: indexPath) as! CustomUpcomingBookingTVC
        
        let dict : BookingClassModel = arrUpcomingBookingData[indexPath.row]
        cell.classNameLbl.text = dict.classDetails.name
        
        if isStudentLogin() {
            
            cell.userNameLbl.text = getFirstName(name: dict.teacher.name)

        } else {
            
            cell.userNameLbl.text = getFirstName(name: dict.student.name)

        }
        
        cell.priceLbl.text = setFlotingPriceWithCurrency(dict.classDetails.rate)
        
        if dict.slot.count != 0
        {
            cell.dateTimeLbl.text = AppDelegate().sharedDelegate().getDateTimeValueFromSlot(dict.slot)
        }
        
        APIManager.sharedInstance.serviceCallToGetPhoto(dict.classDetails.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [cell.imgBtn])

        cell.cancelBtn.tag = indexPath.row
        cell.cancelBtn.addTarget(self, action: #selector(clickToCancelBtn(_:)), for: .touchUpInside)
        cell.chatBtn.tag = indexPath.row
        cell.chatBtn.addTarget(self, action: #selector(clickToChatBtn(_:)), for: .touchUpInside)
        
        cell.starBtn.isHidden = true
        cell.starView.isHidden = true
        cell.constraintWidthStarView.constant = 100
        cell.chatBtn.isHidden = false
        cell.cancelBtn.isHidden = false
        cell.setCellDesign()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadNextData && (arrUpcomingBookingData.count - 1) == indexPath.row
        {
            serviceCallForUpcomingBookingList()
        }
    }
    
    @IBAction func clickToCancelBtn(_ sender: UIButton) {
        selectedBooking = arrUpcomingBookingData[sender.tag]
        openCancelPopupView()
    }

    @IBAction func clickToChatBtn(_ sender: UIButton) {
        let dict : BookingClassModel = arrUpcomingBookingData[sender.tag]
        if isStudentLogin()
        {
            let receiver : FirebaseUserModel = FirebaseUserModel.init(dict: dict.teacher.dictionary())
            AppDelegate().sharedDelegate().onChannelTap(connectUser: receiver)
        }
        else
        {
            let receiver : FirebaseUserModel = FirebaseUserModel.init(dict: dict.student.dictionary())
            AppDelegate().sharedDelegate().onChannelTap(connectUser: receiver)
        }
    }

    
    func serviceCallForUpcomingBookingList()
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
        dict["bookingType"] = 1
        dict["page"] = page
        dict["limit"] = limit
        
        APIManager.sharedInstance.serviceCallToGetBookingList(dict) { (dictArr) in
            print(dictArr)
            if self.page == 1
            {
                self.arrUpcomingBookingData = [BookingClassModel]()
                for temp in dictArr
                {
                    self.arrUpcomingBookingData.append(BookingClassModel.init(dict: temp))
                }
            }
            else
            {
                for temp in dictArr
                {
                    self.arrUpcomingBookingData.append(BookingClassModel.init(dict: temp))
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
            if self.arrUpcomingBookingData.count == 0
            {
                self.noDataFound.isHidden = false
            }
            else
            {
                self.noDataFound.isHidden = true
            }
        }
    }
    
    
    func openCancelPopupView()
    {
        cancelPopupView.addCornerRadiusOfView(10)
        cancelNoBtn.addCornerRadiusOfView(cancelNoBtn.frame.size.height/2)
        cancelNoBtn.applyBorderOfView(width: 1, borderColor: colorFromHex(
            hex: COLOR.APP_COLOR))
        cancelYesBtn.addCornerRadiusOfView(cancelNoBtn.frame.size.height/2)
        displaySubViewtoParentView(AppDelegate().sharedDelegate().window, subview: cancelContainerView)
    }
    
    @IBAction func clickToNo(_ sender: Any) {
        cancelContainerView.removeFromSuperview()
    }
    
    @IBAction func clickToYes(_ sender: Any) {
        cancelContainerView.removeFromSuperview()
        var param : [String : Any] = [String : Any]()
        param["bookingId"] = selectedBooking.id
    //    param["confirmed"] = false
        APIManager.sharedInstance.serviceCallToCancelBookingAction(param) { (isSuccess) in
            
            if isSuccess {
                
                displayToast("Booking Cancelled Successfully.")
                self.serviceCallForUpcomingBookingList()
                
            }
            
            let index = self.arrUpcomingBookingData.index(where: { (temp) -> Bool in
                temp == self.selectedBooking
            })
            if index != nil
            {
                self.selectedBooking.confirmed = 1
                self.arrUpcomingBookingData[index!] = self.selectedBooking
                self.tblView.reloadData()
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
