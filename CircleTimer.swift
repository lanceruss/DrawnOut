//
//  CircleTimer.swift
//  Fictionary
//
//  Created by Caleb Talbot on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit
import GLKit

class CircleTimer: UIView {

    // MARK: Properties
    let centerX:CGFloat = 55
    let centerY:CGFloat = 55
    let radius:CGFloat = 50
    
    var currentAngle:Float = 270
    
    let timeBetweenDraw:CFTimeInterval = 0.01
    
    // MARK: Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.clearColor()
        NSTimer.scheduledTimerWithTimeInterval(timeBetweenDraw, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    // MARK: Drawing
    func updateTimer() {
        
        if currentAngle <= 270 && currentAngle > -90 {
            currentAngle -= 1
            setNeedsDisplay()
            
            print(currentAngle)
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        let path = CGPathCreateMutable()
        
        CGPathAddArc(path, nil, centerX, centerY, radius, -CGFloat(M_PI/2), CGFloat(GLKMathDegreesToRadians(currentAngle)), false)
        
        CGContextAddPath(context, path)
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextSetLineWidth(context, 5)
        CGContextStrokePath(context)
    }
}