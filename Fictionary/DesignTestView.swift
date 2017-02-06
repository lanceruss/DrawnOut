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
    override func draw(_ rect: CGRect) {
        print("drawRect")
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1.0)
        //        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        let components: [CGFloat] = [1.0, 1.0, 1.0, 1.0]
        //        let color = CGColorCreate(colorSpace, components)
        context?.setStrokeColor(UIColor.white.cgColor)
        
        context?.move(to: CGPoint(x: (UIScreen.main.bounds.width / 2) - 136.25, y: 93))
        context?.addLine(to: CGPoint(x: (UIScreen.main.bounds.width / 2) + 136.25, y: 93))
        context?.strokePath()
        
        let context2 = UIGraphicsGetCurrentContext()
        context2?.setLineWidth(1.0)
        //        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        let components: [CGFloat] = [1.0, 1.0, 1.0, 1.0]
        //        let color = CGColorCreate(colorSpace, components)
        context2?.setStrokeColor(UIColor.white.cgColor)
        
        context2?.move(to: CGPoint(x: (UIScreen.main.bounds.width / 2) - 136.25, y: 147.5))
        context2?.addLine(to: CGPoint(x: (UIScreen.main.bounds.width / 2) + 136.25, y: 147.5))
        context2?.strokePath()
    }
    
}
