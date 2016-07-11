//
//  RevisedCircleTimerView.swift
//  Fictionary
//
//  Created by Caleb Talbot on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class RevisedCircleTimerView: UIView {

    let timeLeftShapeLayer = CAShapeLayer()
    let bgShapeLayer = CAShapeLayer()
    
    var timeLeft: NSTimeInterval?
    var endTime: NSDate!
    
    var timeLabel = UILabel()
    var timer = NSTimer()
    
    let strokeIt = CABasicAnimation(keyPath: "strokeEnd")
    
    func setUpTimer(numberOfSeconds: Double) {
        
        timeLeft = numberOfSeconds
        
        self.backgroundColor = UIColor.pastelGreen()
        
        drawBgShape()
        drawTimeLeftShape()
        addTimeLabel()
        
        strokeIt.fromValue = 0.0
        strokeIt.toValue = 1.0
        strokeIt.duration = 60.0
        
        timeLeftShapeLayer.addAnimation(strokeIt, forKey: nil)
        endTime = NSDate().dateByAddingTimeInterval(timeLeft!)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    func drawBgShape() {
        bgShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.midX , y: self.frame.midY), radius: 100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).CGPath
        bgShapeLayer.strokeColor = UIColor.orangeColor().CGColor
        bgShapeLayer.fillColor = UIColor.greenColor().CGColor
        bgShapeLayer.lineWidth = 15
        self.layer.addSublayer(bgShapeLayer)
    }
    
    func drawTimeLeftShape() {
        timeLeftShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.midX, y: self.frame.midY), radius: 100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).CGPath
        timeLeftShapeLayer.strokeColor = UIColor.redColor().CGColor
        timeLeftShapeLayer.fillColor = UIColor.blueColor().CGColor
        timeLeftShapeLayer.lineWidth = 15
        self.layer.addSublayer(timeLeftShapeLayer)
    }
    
    func addTimeLabel() {
        timeLabel = UILabel(frame: CGRectMake(self.frame.midX-50, self.frame.midY-25, 100, 50))
        timeLabel.textAlignment = .Center
        timeLabel.text = timeLeft!.time
        self.addSubview(timeLabel)
    }
    
    func updateTime() {
        if timeLeft > 0 {
            timeLeft = endTime.timeIntervalSinceNow
            timeLabel.text = timeLeft!.time
        } else {
            timeLabel.text = "00:00"
            timer.invalidate()
        }
    }
    

}

extension Double {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.00
    }
}

extension NSTimeInterval {
    var time: String {
        return String(format: "%02d:%02d", Int(self/60.0), Int(ceil(self%60)))
    }
}

