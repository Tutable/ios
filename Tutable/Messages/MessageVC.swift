//
//  MessageVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class MessageVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    var arrMessage : [InboxListModel] = [InboxListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(updateInboxList), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_INBOX_LIST), object: nil)
        
        
        tblView.backgroundColor = UIColor.clear
        tblView.separatorStyle = UITableViewCellSeparatorStyle.none
        tblView.tableFooterView = UIView(frame: CGRect.zero)
        tblView.register(UINib(nibName: "CustomMessagesTVC", bundle: nil), forCellReuseIdentifier: "CustomMessagesTVC")
        
        noDataFoundLbl.isHidden = true
        updateInboxList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
    }
    
    @objc func updateInboxList()
    {
        arrMessage = [InboxListModel] ()
        for i in 0..<AppModel.shared.INBOXLIST.count
        {
            if (AppDelegate().sharedDelegate().isMyChanel(channelId: AppModel.shared.INBOXLIST[i].id)) && (AppModel.shared.INBOXLIST[i].lastMessage.msgId != "")
            {
                arrMessage.append(AppModel.shared.INBOXLIST[i])
            }
        }
        if arrMessage.count > 1
        {
            arrMessage.sort {
                let elapsed0 = $0.lastMessage.date
                let elapsed1 = $1.lastMessage.date
                return elapsed0! > elapsed1!
            }
        }
        
        tblView.reloadData()
        if arrMessage.count == 0
        {
            noDataFoundLbl.isHidden = false
        }
        else
        {
            noDataFoundLbl.isHidden = true
        }
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessage.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomMessagesTVC", for: indexPath) as! CustomMessagesTVC
        let dict : InboxListModel = arrMessage[indexPath.row]
        let dictMsg : MessageModel = dict.lastMessage
        
        let otherUserId : String = AppDelegate().sharedDelegate().getOtherUserID(channelID: dict.id)
        let index = AppModel.shared.USERS.index { (temp) -> Bool in
            temp.id == otherUserId
        }
        
        if index != nil
        {
            let otherUser : FirebaseUserModel = AppModel.shared.USERS[index!]
            APIManager.sharedInstance.serviceCallToGetPhoto(otherUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [cell.imageBtn])
            cell.nameLbl.text = otherUser.name
            if otherUser.last_seen == ""
            {
                cell.statusImgView.backgroundColor = colorFromHex(hex: COLOR.APP_COLOR)
            }
            else if getDifferenceFromCurrentTime(Double(otherUser.last_seen)!) < 60
            {
                cell.statusImgView.backgroundColor = colorFromHex(hex: COLOR.ORANGE_COLOR)
            }
            else
            {
                cell.statusImgView.backgroundColor = colorFromHex(hex: COLOR.LIGHT_GRAY)
            }
        }
        
        cell.messageLbl.text = dictMsg.text
        cell.dataLbl.text = getDateStringFromDate(date: getDateFromTimeStamp(Double(dictMsg.date)!), format: "dd MMM yyyy")
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let otherUserId : String = AppDelegate().sharedDelegate().getOtherUserID(channelID: arrMessage[indexPath.row].id)
        let index = AppModel.shared.USERS.index { (temp) -> Bool in
            temp.id == otherUserId
        }
        
        if index != nil
        {
            let vc : ChatViewController = STORYBOARD.MESSAGE.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.channelId = arrMessage[indexPath.row].id
            vc.receiver = AppModel.shared.USERS[index!]
            self.navigationController?.pushViewController(vc, animated: true)
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
