//
//  InstructionsViewController.swift
//  Fictionary
//
//  Created by Caleb Talbot on 7/13/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.medAquamarine()
        
        titleView.backgroundColor = UIColor.pastelGreen()
        titleView.layer.shadowColor = UIColor.blackColor().CGColor
        titleView.layer.shadowOpacity = 0.25
        titleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleView.layer.shadowRadius = 3.5
        
        doneButton.layer.cornerRadius = 0.5 * doneButton.bounds.size.height
        doneButton.backgroundColor = UIColor.shamrock()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
