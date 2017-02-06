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
    
    func execute(_ canvas: Canvas) {
        
        canvas.context.setFillColor(self.color.cgColor)
        
        canvas.context.addArc(center: center,
                              radius: radius,
                              startAngle: 0,
                              endAngle: 2 * CGFloat(M_PI),
                              clockwise: true)
        //canvas.context.addArc(withCenter center: CGPoint(self.center.x, self.center.y),
//               radius: radius,
//               startAngle: 0,
//               endAngle:  2 * CGFloat(M_PI),
//               clockwise: true)
        //CGContextAddArc(canvas.context, self.center.x, self.center.y, self.radius, 0, 2 * CGFloat(M_PI), 1)
        (canvas.context).fillPath()
    }
}
