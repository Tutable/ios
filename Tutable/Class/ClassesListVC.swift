//
//  ClassesListVC.swift
//  Tutable
//
//  Created by Keyur on 27/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class ClassesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var tblView: UITableView!

    var teacherData : UserModel!
    var classData : [ClassModel] = [ClassModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblView.register(UINib(nibName: "CustomClassesTVC", bundle: nil), forCellReuseIdentifier: "CustomClassesTVC")
        titleLbl.text = "All Classes"
        getClassList()
    }
    
    func getClassList()
    {
        APIManager.sharedInstance.serviceCallToGetClassList("", teacherId: teacherData.id) { (dataArr) in
            self.classData = [ClassModel]()
            for temp in dataArr
            {
                self.classData.append(ClassModel.init(dict: temp))
            }
            self.tblView.reloadData()
            if self.classData.count == 0
            {
                self.noDataFoundLbl.isHidden = false
            }
            else
            {
                self.noDataFoundLbl.isHidden = true
            }
        }
    }
    
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Tableview Delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "CustomClassesTVC", for: indexPath) as! CustomClassesTVC
        
        let dict : ClassModel = classData[indexPath.row]
        
        APIManager.sharedInstance.serviceCallToGetPhoto(dict.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [cell.imgBtn])
        cell.titleLbl.text = dict.name
        if let avgStars = dict.reviews["avgStars"] as? Double
        {
            cell.starBtn.setTitle(String(Int(avgStars)), for: .normal)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : ClassDetailVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "ClassDetailVC") as! ClassDetailVC
        vc.classId = classData[indexPath.row].id
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
