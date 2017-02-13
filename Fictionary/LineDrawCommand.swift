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
    
    func execute(_ canvas: Canvas) {
        
        self.configure(canvas)
        
        if self.previous != nil {
            self.drawQuadraticCurve(canvas)
        } else {
            self.drawLine(canvas)
        }
    }
    
    func configure(_ canvas: Canvas) {
        
        canvas.context.setStrokeColor(self.color.cgColor)
        canvas.context.setLineWidth(self.width)
        canvas.context.setLineCap(.round)
    }
    
    func drawLine(_ canvas: Canvas) {
        
        canvas.context.move(to: CGPoint(x: self.current.a.x, y: self.current.a.y))
        canvas.context.addLine(to: CGPoint(x: self.current.b.x, y: self.current.b.y))
        canvas.context.strokePath()
    }
    
    func drawQuadraticCurve(_ canvas: Canvas) {
        
        if let previousMid = self.previous?.midPoint {
            
            let currentMid = self.current.midPoint
            
            canvas.context.move(to: CGPoint(x: previousMid.x, y: previousMid.y))
            canvas.context.addQuadCurve(to: CGPoint(x: current.a.x, y: current.a.y), control: CGPoint(x: currentMid.x, y: currentMid.y))
            //CGContextAddQuadCurveToPoint(canvas.context, current.a.x, current.a.y, currentMid.x, currentMid.y)
            canvas.context.strokePath()
        }
    }
}
