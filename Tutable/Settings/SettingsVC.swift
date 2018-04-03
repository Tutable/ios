//
//  SettingsVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblView: UITableView!

    var arrData : [[String : String]] = [["image" : "information", "name" : "Help"],["image" : "account", "name" : "Account Details"],["image" : "logo_green", "name" : "About"],["image" : "logout", "name" : "Log out"],["image" : "", "name" : "Delete Account"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomSettingTVC", bundle: nil), forCellReuseIdentifier: "CustomSettingTVC")
        tblView.backgroundColor = UIColor.clear
        tblView.setInnerViewShadow(colorFromHex(hex: COLOR.SHADOW_GRAY))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
    }
    
    // MARK: - Tableview Delegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomSettingTVC", for: indexPath) as! CustomSettingTVC
        let dict : [String : String] = arrData[indexPath.row]
        
        cell.titleLbl.text = dict["name"]
        if dict["image"] == ""
        {
            cell.constraintWidthImgBtn.constant = 0
            cell.imgBtn.isHidden = true
            cell.titleLbl.textColor = UIColor.red
            cell.seperateImgView.isHidden = true
        }
        else
        {
            cell.imgBtn.setImage(UIImage.init(named: dict["image"]!), for: .normal)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            
            break
        case 1:
            
            break
        case 2:
            
            break
        case 3:
            logoutUser()
            break
        default:
            break
        }
    }
    
    func logoutUser()
    {
        let alert = UIAlertController(title: "Tutable", message: "Are you sure you want to Logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
            AppDelegate().sharedDelegate().logoutApp()
        }))
        self.present(alert, animated: true, completion: nil)
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
