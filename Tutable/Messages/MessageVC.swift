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
    var items = [Conversation]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        NotificationCenter.default.addObserver(self, selector: #selector(updateInboxList), name: NSNotification.Name(rawValue: NOTIFICATION.UPDATE_INBOX_LIST), object: nil)//Comment on 6-Oct-2018
        
        
        tblView.backgroundColor = UIColor.clear
        tblView.separatorStyle = UITableViewCellSeparatorStyle.none
        tblView.tableFooterView = UIView(frame: CGRect.zero)
        tblView.register(UINib(nibName: "CustomMessagesTVC", bundle: nil), forCellReuseIdentifier: "CustomMessagesTVC")
        
        noDataFoundLbl.isHidden = false
       // updateInboxList() Comment on 6-Oct-2018
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if tabBarController != nil
        {
            let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
            tabBar.setTabBarHidden(tabBarHidden: false)
        }
        fetchData()
        if AppModel.shared.INBOXLIST.count == 0
        {
            //AppDelegate().sharedDelegate().inboxListHandler()//comment on 4-Oct-2018
        }
        
    }
    
    @objc func updateInboxList()
    {   
        arrMessage = [InboxListModel] ()
        print(AppModel.shared.INBOXLIST.count)
        for i in 0..<AppModel.shared.INBOXLIST.count
        {
            if (AppDelegate().sharedDelegate().isMyChanel(channelId: AppModel.shared.INBOXLIST[i].id)) && (AppModel.shared.INBOXLIST[i].lastMessage.msgId != "")
            {
                arrMessage.append(AppModel.shared.INBOXLIST[i])
                print(arrMessage.count)
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
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
        
        
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
        //return arrMessage.count//Comment on 6-Oct-2018
         return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tblView.dequeueReusableCell(withIdentifier: "CustomMessagesTVC", for: indexPath) as? CustomMessagesTVC else{
            return UITableViewCell()
        }
        cell.nameLbl.text = self.items[indexPath.row].user.name
      cell.imageBtn.setImage(self.items[indexPath.row].user.profilePic, for: UIControlState.normal)
        cell.messageLbl.text = self.items[indexPath.row].lastMessage.content as? String
        print(self.items[indexPath.row].lastMessage.timestamp)
        //cell.dataLbl.text = "\(self.items[indexPath.row].lastMessage.timestamp)"
        
        return cell
        
//        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomMessagesTVC", for: indexPath) as! CustomMessagesTVC
//
//        let dict : InboxListModel = arrMessage[indexPath.row]
//        let dictMsg : MessageModel = dict.lastMessage
//
//        let otherUserId : String = AppDelegate().sharedDelegate().getOtherUserID(channelID: dict.id)
//        let index = AppModel.shared.USERS.index { (temp) -> Bool in
//            temp.id == otherUserId
//        }
//
//        if index != nil
//        {
//            let otherUser : FirebaseUserModel = AppModel.shared.USERS[index!]
//            APIManager.sharedInstance.serviceCallToGetPhoto(otherUser.picture, placeHolder: IMAGE.USER_PLACEHOLDER, btn: [cell.imageBtn])
//            cell.nameLbl.text = getFirstName(name: otherUser.name)
//            if otherUser.last_seen == ""
//            {
//                cell.statusImgView.backgroundColor = colorFromHex(hex: COLOR.APP_COLOR)
//            }
//            else if getDifferenceFromCurrentTime(Double(otherUser.last_seen)!) < 60
//            {
//                cell.statusImgView.backgroundColor = colorFromHex(hex: COLOR.ORANGE_COLOR)
//            }
//            else
//            {
//                cell.statusImgView.backgroundColor = colorFromHex(hex: COLOR.LIGHT_GRAY)
//            }
//        }
//
//        cell.messageLbl.text = dictMsg.text.decoded
//        cell.dataLbl.text = getDateTimeStringForChat(Double(dictMsg.date)!)
//
//        cell.selectionStyle = UITableViewCellSelectionStyle.none
//        return cell
        //Comment on 6-Oct-2018
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         let vc : ChatController = STORYBOARD.MESSAGE.instantiateViewController(withIdentifier: "ChatController") as! ChatController
          vc.currentUser = self.items[indexPath.row].user
          vc.TitleLbl = self.items[indexPath.row].user.name
         self.navigationController?.pushViewController(vc, animated: true)
        
//        let otherUserId : String = AppDelegate().sharedDelegate().getOtherUserID(channelID: arrMessage[indexPath.row].id)
//        let index = AppModel.shared.USERS.index { (temp) -> Bool in
//            temp.id == otherUserId
//        }
//
//        if index != nil
//        {
//            let vc : ChatViewController = STORYBOARD.MESSAGE.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
//            vc.channelId = arrMessage[indexPath.row].id
//            vc.receiver = AppModel.shared.USERS[index!]
//            self.navigationController?.pushViewController(vc, animated: true)
//        }//Comment on 6-Oct-2018
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //Downloads conversations
    func fetchData() {
        showLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            removeLoader()
        })
        Conversation.showConversations { (conversations) in
            self.items = conversations
            self.items.sort{ $0.lastMessage.timestamp > $1.lastMessage.timestamp }
            if self.items.count > 0{
                DispatchQueue.main.async {
                    
                    self.noDataFoundLbl.isHidden = true
                }
                
            }
            else{
                DispatchQueue.main.async {
                    
                 
                   self.noDataFoundLbl.isHidden = false
                }
                
            }
            DispatchQueue.main.async {
                self.tblView.reloadData()
                for conversation in self.items {
                    if conversation.lastMessage.isRead == false {
                        //self.playSound()
                        break
                    }
                }
            }
            
        }
        
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
