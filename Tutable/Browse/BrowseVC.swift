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
    }

    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
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
        
    }
    
    // MARK: - Collectionview Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = tutableCollectioView.dequeueReusableCell(withReuseIdentifier: "CustomCategoryCVC", for: indexPath) as! CustomCategoryCVC
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellH : CGFloat = collectionView.frame.size.height/3
        let cellW : CGFloat = collectionView.frame.size.width/2
        return CGSize(width: cellW, height: cellH)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc : EntertainmentVC = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "EntertainmentVC") as! EntertainmentVC
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
