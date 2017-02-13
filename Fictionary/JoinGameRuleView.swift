//
//  JoinGameRuleView.swift
//  Fictionary
//
//  Created by Caleb Talbot on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class JoinGameRuleView: UIView {

        override func draw(_ rect: CGRect) {
            
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(1.0)
            context?.setStrokeColor(UIColor.white.cgColor)
            
            context?.move(to: CGPoint(x: (UIScreen.main.bounds.width / 2) - 136.25, y: (UIScreen.main.bounds.height / 2)))
            context?.addLine(to: CGPoint(x: (UIScreen.main.bounds.width / 2) + 136.25, y: (UIScreen.main.bounds.height / 2)))
            context?.strokePath()
    }

}
