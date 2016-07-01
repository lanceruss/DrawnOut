//
//  DrawViewController.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController {
    
    private var drawController: FreehandDrawController!

    var recievedCaption: String?
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    var secondsAllowed = 25
    var seconds = 0
    var timer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.drawController = FreehandDrawController(canvas: self.drawView, view: self.drawView)
        self.drawController.width = 4.2
        
        self.drawView.multipleTouchEnabled = true
        
        captionLabel.text = recievedCaption
        
        seconds = secondsAllowed
        timerLabel.text = "\(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(TimerViewController.subtractTime), userInfo: nil, repeats: true)

    }
    
    var drawView: DrawView {
        return self.view as! DrawView
    }
    
    func subtractTime() {
        
        seconds-=1
        timerLabel.text = "\(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
            performSegueWithIdentifier("ToCaption", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToCaption" {
        let dvc = segue.destinationViewController as! CaptionPhotoViewController
        let passImage = UIImage(CGImage: self.drawView.buffer!.CGImage!)
        dvc.drawnImage = passImage
        }
    }



}
