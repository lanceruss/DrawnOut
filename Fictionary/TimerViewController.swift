//
//  TimerViewController.swift
//  Fictionary
//
//  Created by Ernie Barojas on 6/28/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    var seconds = 0
    var timer = Timer()
    var secondsAllowed = 45
    
    @IBAction func dismissButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGame()
    
    }
    
    func subtractTime() {
        seconds-=1
        timeLabel.text = "Time: \(seconds)"
        
        if seconds == 0 {
            timer.invalidate()
        }
    }
    
    func setupGame() {
        seconds = secondsAllowed
        timeLabel.text = "Time: \(seconds)"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TimerViewController.subtractTime), userInfo: nil, repeats: true)
    }

    @IBAction func onButtonTapped(_ sender: AnyObject) {
        // reset counter
        timer.invalidate()
        setupGame()
    }

}
