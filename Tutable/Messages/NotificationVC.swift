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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomNotificationTVC", bundle: nil), forCellReuseIdentifier: "CustomNotificationTVC")
        tblView.register(UINib(nibName: "CustomAcceptRejectNotiTVC", bundle: nil), forCellReuseIdentifier: "CustomAcceptRejectNotiTVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0
        {
            return 100
        }
        else
        {
            return 85
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            let cell = tblView.dequeueReusableCell(withIdentifier: "CustomAcceptRejectNotiTVC", for: indexPath) as! CustomAcceptRejectNotiTVC
            
            let noramlText : String = "KEYUR requested for DANCE"

            let attributedString = NSMutableAttributedString(string:noramlText)
            let attrs : [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : colorFromHex(hex: COLOR.DARK_TEXT)]
            attributedString.addAttributes(attrs, range: (noramlText as NSString).range(of: "KEYUR"))
            attributedString.addAttributes(attrs, range: (noramlText as NSString).range(of: "DANCE"))
            cell.titleLbl.attributedText = attributedString
            
            cell.acceptBtn.tag = indexPath.row
            cell.acceptBtn.addTarget(self, action: #selector(clickToAccept(_:)), for: .touchUpInside)
            cell.rejectBtn.tag = indexPath.row
            cell.rejectBtn.addTarget(self, action: #selector(clickToReject(_:)), for: .touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else
        {
            let cell = tblView.dequeueReusableCell(withIdentifier: "CustomNotificationTVC", for: indexPath) as! CustomNotificationTVC
            
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }

    @IBAction func clickToAccept(_ sender: UIButton) {
        
    }
    
    @IBAction func clickToReject(_ sender: UIButton) {
        
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
