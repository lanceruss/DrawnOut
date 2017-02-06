//
//  RevisedCircleTimerView.swift
//  Fictionary
//
//  Created by Caleb Talbot on 7/11/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class RevisedCircleTimerView: UIView {

    let timeLeftShapeLayer = CAShapeLayer()
    let bgShapeLayer = CAShapeLayer()
    
    var timeLeft: TimeInterval?
    var endTime: Date!
    
    var timeLabel = UILabel()
    var timer = Timer()
    
    let strokeIt = CABasicAnimation(keyPath: "strokeEnd")
    
    func setUpTimer(_ numberOfSeconds: Double) {
        
        timeLeft = numberOfSeconds
        
        self.backgroundColor = UIColor.pastelGreen()
        
        drawBgShape()
        drawTimeLeftShape()
        addTimeLabel()
        
        strokeIt.fromValue = 0.0
        strokeIt.toValue = 1.0
        strokeIt.duration = 60.0
        
        timeLeftShapeLayer.add(strokeIt, forKey: nil)
        endTime = Date().addingTimeInterval(timeLeft!)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
    }
    
    func drawBgShape() {
        bgShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.midX , y: self.frame.midY), radius: 100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        bgShapeLayer.strokeColor = UIColor.orange.cgColor
        bgShapeLayer.fillColor = UIColor.green.cgColor
        bgShapeLayer.lineWidth = 15
        self.layer.addSublayer(bgShapeLayer)
    }
    
    func drawTimeLeftShape() {
        timeLeftShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.midX, y: self.frame.midY), radius: 100, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        timeLeftShapeLayer.strokeColor = UIColor.red.cgColor
        timeLeftShapeLayer.fillColor = UIColor.blue.cgColor
        timeLeftShapeLayer.lineWidth = 15
        self.layer.addSublayer(timeLeftShapeLayer)
    }
    
    func addTimeLabel() {
        timeLabel = UILabel(frame: CGRect(x: self.frame.midX-50, y: self.frame.midY-25, width: 100, height: 50))
        timeLabel.textAlignment = .center
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

extension TimeInterval {
    var time: String {
        return String(format: "%02d:%02d", Int(self/60.0), Int(ceil(self.truncatingRemainder(dividingBy: 60))))
    }
}

