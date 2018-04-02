//
//  MyClassVC.swift
//  Tutable
//
//  Created by Keyur on 02/04/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class MyClassVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var notiCountLbl: UILabel!
    @IBOutlet weak var addClassBtn: UIButton!
    
    var myClassData : [[String : Any]] = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomMyClassTVC", bundle: nil), forCellReuseIdentifier: "CustomMyClassTVC")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
        
        getClassList()
    }
    
    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        notiCountLbl.addCornerRadiusOfView(notiCountLbl.frame.size.width/2)
    }
    
    func getClassList()
    {
        APIManager.sharedInstance.serviceCallToGetClassList { (dataArr) in
            print(dataArr)
            self.myClassData = dataArr
            self.tblView.reloadData()
        }
    }
    
    
    // MARK: - Button click event
    @IBAction func clickToNotification(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickToAddClass(_ sender: Any) {
        self.view.endEditing(true)
        let vc : AddClassVC = self.storyboard?.instantiateViewController(withIdentifier: "AddClassVC") as! AddClassVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myClassData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomMyClassTVC", for: indexPath) as! CustomMyClassTVC
        let dict : [String : Any] = myClassData[indexPath.row]
        
        cell
        
        cell.setCellDesign()
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
