//
//  DesignTestViewController.swift
//  Fictionary
//
//  Created by Lance Russ on 7/7/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class DesignTestViewController: UIViewController {

    @IBOutlet var startButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var profileButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.pastelGreen()
        startButton.backgroundColor = UIColor.shamrock()
        startButton.layer.cornerRadius = 0.5 * startButton.bounds.size.height
        loginButton.backgroundColor = UIColor.medAquamarine()
        loginButton.layer.cornerRadius = 0.5 * loginButton.bounds.size.height
        profileButton.backgroundColor = UIColor.medAquamarine()
        profileButton.layer.cornerRadius = 0.5 * profileButton.bounds.size.height

    }
    
    var drawView: DesignTestView {
        return self.view as! DesignTestView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.barTintColor = UIColor.white
       // let navBarAppearance = UINavigationBar.appearance()
       // navBarAppearance.tintColor = UIColor.whiteColor()
       // navBarAppearance.barTintColor = UIColor(red:0.48, green:0.92, blue:0.51, alpha:1.00)
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

    }

    @IBAction func createAccountButtonPressed(_ sender: AnyObject) {
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
