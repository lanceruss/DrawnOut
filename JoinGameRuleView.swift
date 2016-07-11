//
//  JoinGameRuleView.swift
//  Fictionary
//
//  Created by Caleb Talbot on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class JoinGameRuleView: UIView {

        override func drawRect(rect: CGRect) {
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            
            CGContextMoveToPoint(context, (UIScreen.mainScreen().bounds.width / 2) - 136.25, (UIScreen.mainScreen().bounds.height / 2))
            CGContextAddLineToPoint(context, (UIScreen.mainScreen().bounds.width / 2) + 136.25, (UIScreen.mainScreen().bounds.height / 2))
            CGContextStrokePath(context)
    }

}
