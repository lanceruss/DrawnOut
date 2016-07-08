//
//  DesignTestView.swift
//  Fictionary
//
//  Created by Lance Russ on 7/8/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class DesignTestView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        print("drawRect")
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        //        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        let components: [CGFloat] = [1.0, 1.0, 1.0, 1.0]
        //        let color = CGColorCreate(colorSpace, components)
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        
        CGContextMoveToPoint(context, (UIScreen.mainScreen().bounds.width / 2) - 136.25, 93)
        CGContextAddLineToPoint(context, (UIScreen.mainScreen().bounds.width / 2) + 136.25, 93)
        CGContextStrokePath(context)
        
        let context2 = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context2, 1.0)
        //        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        let components: [CGFloat] = [1.0, 1.0, 1.0, 1.0]
        //        let color = CGColorCreate(colorSpace, components)
        CGContextSetStrokeColorWithColor(context2, UIColor.whiteColor().CGColor)
        
        CGContextMoveToPoint(context2, (UIScreen.mainScreen().bounds.width / 2) - 136.25, 147.5)
        CGContextAddLineToPoint(context2, (UIScreen.mainScreen().bounds.width / 2) + 136.25, 147.5)
        CGContextStrokePath(context2)
    }
    
}
