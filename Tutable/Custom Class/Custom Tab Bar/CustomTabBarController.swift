//
//  CustomTabBarController.swift
//  Event Project
//
//  Created by Keyur on 20/07/17.
//  Copyright © 2017 AK Infotech. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, CustomTabBarViewDelegate {

    
    var tabBarView : CustomTabBarView = CustomTabBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.view.layoutIfNeeded()
        
        tabBarView = Bundle.main.loadNibNamed("CustomTabBarView", owner: nil, options: nil)?.last as! CustomTabBarView
        
        tabBarView.delegate = self
        
        addTabBarView()
        
        setup()
        //tabBarView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.redirectToNotification(noti:)), name: NSNotification.Name.init(rawValue: NOTIFICATION.REDIRECT_TO_NOTIFICATION), object: nil)
    }
    
    @objc func redirectToNotification(noti : Notification)
    {
        tabBarView.resetAllButton()
        tabBarView.btn4.isSelected = true;
        tabBarView.lbl4.isHighlighted = true;
        tabSelectedAtIndex(index: 3)
    }
    
    func setup()
    {
        var viewControllers = [UINavigationController]()
        let navController1 : UINavigationController = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "ProfileVCNavigation") as! UINavigationController
        viewControllers.append(navController1)
        
        let navController2 : UINavigationController = STORYBOARD.BOOKING.instantiateViewController(withIdentifier: "BookingVCNavigation") as! UINavigationController
        viewControllers.append(navController2)
        
        if isStudentLogin()
        {
            let navController3 : UINavigationController = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "BrowseVCNavigation") as! UINavigationController
            viewControllers.append(navController3)
            tabBarView.lbl3.text = "BROWSE"
        }
        else
        {
            let navController3 : UINavigationController = STORYBOARD.CLASS.instantiateViewController(withIdentifier: "MyClassVCNavigation") as! UINavigationController
            viewControllers.append(navController3)
            tabBarView.lbl3.text = "MY CLASSES"
        }
        
        let navController4 : UINavigationController = STORYBOARD.MESSAGE.instantiateViewController(withIdentifier: "MessageVCNavigation") as! UINavigationController
        viewControllers.append(navController4)
        
        let navController5 : UINavigationController = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "SettingsVCNavigation") as! UINavigationController
        viewControllers.append(navController5)
        
        self.viewControllers = viewControllers;
        
        self.tabBarView.btn3.isSelected = true;
        self.tabBarView.lbl3.isHighlighted = true;
        self.tabSelectedAtIndex(index: 2)
    }
 
    func tabSelectedAtIndex(index: Int) {
        setSelectedViewController(selectedViewController: self.viewControllers![index], tabIndex: index)
    }
    
    func setSelectedViewController(selectedViewController:UIViewController, tabIndex:Int)
    {
        // pop to root if tapped the same controller twice
        if self.selectedViewController == selectedViewController {
            (self.selectedViewController as! UINavigationController).popToRootViewController(animated: true)
        }
        super.selectedViewController = selectedViewController
    }
    
    func addTabBarView()
    {
        self.tabBarView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tabBarView)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.tabBarView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 50.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.tabBarView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.tabBarView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: ((UIScreen.main.bounds.height == 812) ? -34 : 0)))
        self.view.addConstraint(NSLayoutConstraint(item: self.tabBarView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
        self.view.layoutIfNeeded()
    }
 
    func tabBarHidden() -> Bool
    {
        return self.tabBarView.isHidden && self.tabBar.isHidden
    }
    
    func setTabBarHidden(tabBarHidden:Bool)
    {
        self.tabBarView.isHidden = tabBarHidden
        self.tabBar.isHidden = true
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
