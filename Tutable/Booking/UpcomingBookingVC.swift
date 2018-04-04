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
    
    var arrUpcomingBookingData : [[String : Any]] = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib.init(nibName: "CustomUpcomingBookingTVC", bundle: nil), forCellReuseIdentifier: "CustomUpcomingBookingTVC")
        tblView.backgroundColor = UIColor.clear
    }

    // MARK: - Tableview Delegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
        return arrUpcomingBookingData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomUpcomingBookingTVC", for: indexPath) as! CustomUpcomingBookingTVC
        
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
    
    @IBAction func clickToCancelBtn(_ sender: UIButton) {
        openCancelPopupView()
    }

    @IBAction func clickToChatBtn(_ sender: UIButton) {
        
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
