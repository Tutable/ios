//
//  ViewController.swift
//  Tutable
//
//  Created by Keyur on 23/03/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var techView: UIView!
    @IBOutlet weak var learnView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        APIManager.sharedInstance.serviceCallToGetHelpAbout()
    }

    override func viewWillLayoutSubviews() {
        setUIDesigning()
    }
    
    func setUIDesigning()
    {
        techView.addCornerRadiusOfView(techView.frame.size.height/2)
        learnView.addCornerRadiusOfView(techView.frame.size.height/2)
    }
    
    
    @IBAction func clickToTech(_ sender: Any) {
        setUserType(type: 1)
        UserDefaults.standard.set("Teacher", forKey: "type")
        let vc : LoginVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToLearn(_ sender: Any) {
        setUserType(type: 2)
        UserDefaults.standard.set("Student", forKey: "type")
        let vc : LoginVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

