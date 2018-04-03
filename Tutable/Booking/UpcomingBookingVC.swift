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
        
        cell.starBtn.isHidden = true
        cell.chatBtn.isHidden = false
        cell.cancelBtn.isHidden = false
        cell.setCellDesign()
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
