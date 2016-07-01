//
//  DrawView.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class DrawView: UIView, Canvas, DrawCommandReceiver {
    
    var buffer: UIImage?
    
    var context: CGContextRef {
        return UIGraphicsGetCurrentContext()!
    }
    
    func reset() {
        self.buffer = nil
        self.layer.contents = nil
    }
    
    func executeCommands(commands: [DrawCommand]) {
        
        autoreleasepool {
            self.buffer = drawInContext { context in
                commands.map { $0.execute(self) }
            }
            self.layer.contents = self.buffer?.CGImage ?? nil
        }
    }
    
    func drawInContext(code:(context: CGContextRef) -> Void) -> UIImage {
        
        let size = self.bounds.size
        
        // Initialize a full size image. Opaque because we don't need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.backgroundColor?.CGColor ?? UIColor.whiteColor().CGColor)
        CGContextFillRect(context, self.bounds)
        
        if let buffer = buffer {
            buffer.drawInRect(self.bounds)
        }
        
        code(context: context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
