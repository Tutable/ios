//
//  BrowseVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class BrowseVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tutableCollectioView: UICollectionView!
    @IBOutlet weak var notiCountLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tutableCollectioView.register(UINib(nibName:"CustomCategoryCVC", bundle: nil), forCellWithReuseIdentifier: "CustomCategoryCVC")
        notiCountLbl.isHidden = true
        if AppModel.shared.categoryData.count == 0
        {
            APIManager.sharedInstance.serviceCallToGetCategory {
                setDataToPreference(data: getDateStringFromDate(date: Date()) as AnyObject, forKey: "category_fetched")
                if getCategoryList().count > 0
                {
                    let data : [[String : Any]] = getCategoryList()
                    AppModel.shared.categoryData = [CategoryModel]()
                    for temp in data
                    {
                        AppModel.shared.categoryData.append(CategoryModel.init(dict: temp))
                    }
                    self.tutableCollectioView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
        
        if AppModel.shared.currentUser.notifications > 0
        {
            notiCountLbl.text = String(AppModel.shared.currentUser.notifications)
            notiCountLbl.isHidden = false
        }
        else
        {
            notiCountLbl.text = ""
            notiCountLbl.isHidden = true
        }
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        notiCountLbl.addCornerRadiusOfView(notiCountLbl.frame.size.width/2)
    }
    
    // MARK: - Button click event
    @IBAction func clickToNotification(_ sender: Any) {
        let vc : NotificationVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Collectionview Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppModel.shared.categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = tutableCollectioView.dequeueReusableCell(withReuseIdentifier: "CustomCategoryCVC", for: indexPath) as! CustomCategoryCVC
        cell.imgBtn.setBackgroundImage(nil, for: .normal)
        let categoryDict : CategoryModel = AppModel.shared.categoryData[indexPath.row]
        cell.titleLbl.text = categoryDict.title
        
        APIManager.sharedInstance.serviceCallToGetPhoto(categoryDict.picture, placeHolder: IMAGE.CAMERA_PLACEHOLDER, btn: [cell.imgBtn])

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellH : CGFloat = collectionView.frame.size.height/3
        let cellW : CGFloat = collectionView.frame.size.width/2
        return CGSize(width: cellW, height: cellH)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc : SubClassVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "SubClassVC") as! SubClassVC
        vc.categoryData = AppModel.shared.categoryData[indexPath.row]
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
