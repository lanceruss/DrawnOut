//
//  DesignCreateAccountViewController.swift
//  Fictionary
//
//  Created by Lance Russ on 7/8/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class DesignCreateAccountViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.pastelGreen()
        emailTextField.borderStyle = UITextBorderStyle.RoundedRect
        emailTextField.layer.borderColor = UIColor.whiteColor().CGColor //huh, no luck.
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.masksToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
