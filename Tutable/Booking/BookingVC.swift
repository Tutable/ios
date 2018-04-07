//
//  BookingVC.swift
//  Tutable
//
//  Created by Keyur on 26/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit
import CarbonKit

class BookingVC: UIViewController, CarbonTabSwipeNavigationDelegate {

    @IBOutlet weak var mainContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tabSwipe = CarbonTabSwipeNavigation(items: ["Upcoming", "Past"], delegate: self)
        tabSwipe.setTabBarHeight(50)
        tabSwipe.setNormalColor(colorFromHex(hex: "21a274"))
        tabSwipe.setSelectedColor(colorFromHex(hex: COLOR.WHITE_COLOR))
        tabSwipe.setIndicatorColor(colorFromHex(hex: COLOR.WHITE_COLOR))
        tabSwipe.carbonSegmentedControl?.setWidth(UIScreen.main.bounds.size.width/2, forSegmentAt: 0)
        tabSwipe.carbonSegmentedControl?.setWidth(UIScreen.main.bounds.size.width/2, forSegmentAt: 1)
        tabSwipe.toolbar.setBackgroundImage(UIImage.init(named: "bg_header"), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        tabSwipe.insert(intoRootViewController: self, andTargetView: mainContainerView)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        let tabBar : CustomTabBarController = self.tabBarController as! CustomTabBarController
        tabBar.setTabBarHidden(tabBarHidden: false)
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        guard let storyboard = storyboard else { return UIViewController() }
        if index == 0 {
            return storyboard.instantiateViewController(withIdentifier: "UpcomingBookingVC")
        }
        else
        {
            return storyboard.instantiateViewController(withIdentifier: "PastBookingVC")
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
