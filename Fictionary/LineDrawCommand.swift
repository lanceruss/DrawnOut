//
//  LineDrawCommand.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

struct LineDrawCommand: DrawCommand {
    
    let current: Segment
    let previous: Segment?
    let width: CGFloat
    let color: UIColor
    
    func execute(canvas: Canvas) {
        
        self.configure(canvas)
        
        if self.previous != nil {
            self.drawQuadraticCurve(canvas)
        } else {
            self.drawLine(canvas)
        }
    }
    
    func configure(canvas: Canvas) {
        
        CGContextSetStrokeColorWithColor(canvas.context, self.color.CGColor)
        CGContextSetLineWidth(canvas.context, self.width)
        CGContextSetLineCap(canvas.context, .Round)
    }
    
    func drawLine(canvas: Canvas) {
        
        CGContextMoveToPoint(canvas.context, self.current.a.x, self.current.a.y)
        CGContextAddLineToPoint(canvas.context, self.current.b.x, self.current.b.y)
        CGContextStrokePath(canvas.context)
    }
    
    func drawQuadraticCurve(canvas: Canvas) {
        
        if let previousMid = self.previous?.midPoint {
            
            let currentMid = self.current.midPoint
            
            CGContextMoveToPoint(canvas.context, previousMid.x, previousMid.y)
            CGContextAddQuadCurveToPoint(canvas.context, current.a.x, current.a.y, currentMid.x, currentMid.y)
            CGContextStrokePath(canvas.context)
        }
    }
}
