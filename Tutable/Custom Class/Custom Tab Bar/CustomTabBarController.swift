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
    }
    
    func setup()
    {
        var viewControllers = [UINavigationController]()
        let navController1 : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVCNavigation") as! UINavigationController
        viewControllers.append(navController1)
        
        let navController2 : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "BookingVCNavigation") as! UINavigationController
        viewControllers.append(navController2)
        
        let navController3 : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "BrowseVCNavigation") as! UINavigationController
        viewControllers.append(navController3)
        
        let navController4 : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "MessageVCNavigation") as! UINavigationController
        viewControllers.append(navController4)
        
        let navController5 : UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVCNavigation") as! UINavigationController
        viewControllers.append(navController5)
        
        self.viewControllers = viewControllers;
        
        self.tabBarView.btn1.isSelected = true;
        self.tabBarView.lbl1.isHighlighted = true;
        self.tabSelectedAtIndex(index: 0)
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
