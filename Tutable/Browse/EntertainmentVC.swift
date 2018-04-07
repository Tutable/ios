//
//  EntertainmentVC.swift
//  VillageApp
//
//  Created by Amisha on 3/24/18.
//  Copyright © 2018 Hash Technocrats. All rights reserved.
//

import UIKit

class EntertainmentVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var classCollectionView: UICollectionView!
    @IBOutlet weak var notiCountLbl: UILabel!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    
    var categoryData : CategoryModel = CategoryModel.init()
    var classData : [ClassModel] = [ClassModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notiCountLbl.isHidden = true
        classCollectionView.register(UINib(nibName:"CustomClassesCVC", bundle: nil), forCellWithReuseIdentifier: "CustomClassesCVC")
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        self.edgesForExtendedLayout = UIRectEdge.bottom
        tabBar.setTabBarHidden(tabBarHidden: true)
        
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
        APIManager.sharedInstance.serviceCallToGetClassList(categoryData.id) { (dataArr) in
            self.classData = [ClassModel]()
            for temp in dataArr
            {
                self.classData.append(ClassModel.init(dict: temp))
            }
            
            self.classCollectionView.reloadData()
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
    
    // MARK: - Button click event
    @IBAction func clickToBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickToNotification(_ sender: Any) {
        let vc : NotificationVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Collection View Method
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = classCollectionView.dequeueReusableCell(withReuseIdentifier: "CustomClassesCVC", for: indexPath) as! CustomClassesCVC
        cell.imgBtn.setBackgroundImage(nil, for: .normal)
        let dict : ClassModel = classData[indexPath.row]
        cell.mainLbl.text = dict.name
        cell.autherLbl.text = "by " + dict.teacher.name
        if dict.teacher.address.suburb != ""
        {
            cell.addressLbl.text = dict.teacher.address.suburb
        }
        if dict.teacher.address.state != ""
        {
            if cell.addressLbl.text != ""
            {
                cell.addressLbl.text = cell.addressLbl.text! + " " + dict.teacher.address.state
            }
            else
            {
                cell.addressLbl.text = dict.teacher.address.state
            }
        }
        APIManager.sharedInstance.serviceCallToGetPhoto(dict.payload, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [cell.imgBtn])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellW : CGFloat = collectionView.frame.size.width/2
        return CGSize(width: cellW, height: (cellW * 230/175))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc : ClassDetailVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "ClassDetailVC") as! ClassDetailVC
        vc.classId = classData[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

}
