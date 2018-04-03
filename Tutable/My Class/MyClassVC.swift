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
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    var myClassData : [ClassModel] = [ClassModel]()
    
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
            
            for temp in dataArr
            {
                self.myClassData.append(ClassModel.init(dict: temp))
            }
            
            self.tblView.reloadData()
            if self.myClassData.count == 0
            {
                self.noDataFoundLbl.isHidden = false
            }
            else
            {
                self.noDataFoundLbl.isHidden = true
            }
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
        let dict : ClassModel = myClassData[indexPath.row]
        cell.className.text = dict.name
        APIManager.sharedInstance.serviceCallToGetClassPhoto(dict.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [cell.classImgBtn])
        cell.priceLbl.text = String(dict.rate)
        cell.setCellDesign()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : ClassDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ClassDetailVC") as! ClassDetailVC
        vc.classId = myClassData[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
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
