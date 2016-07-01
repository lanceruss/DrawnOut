//
//  CircleDrawCommand.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

struct CircleDrawCommand : DrawCommand {
    
    //for the point
    
    let center: CGPoint
    let radius: CGFloat
    let color: UIColor
    
    func execute(canvas: Canvas) {
        
        CGContextSetFillColorWithColor(canvas.context, self.color.CGColor)
        
        CGContextAddArc(canvas.context, self.center.x, self.center.y, self.radius, 0, 2 * CGFloat(M_PI), 1)
        CGContextFillPath(canvas.context)
    }
}
