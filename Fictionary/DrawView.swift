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
    
    var context: CGContext {
        return UIGraphicsGetCurrentContext()!
    }
    
    func reset() {
        self.buffer = nil
        self.layer.contents = nil
    }
    
    func executeCommands(_ commands: [DrawCommand]) {
        
        autoreleasepool {
            self.buffer = drawInContext { context in
                commands.map { $0.execute(self) }
            }
            self.layer.contents = self.buffer?.cgImage ?? nil
        }
    }
    
    func drawInContext(_ code:(_ context: CGContext) -> Void) -> UIImage {
        
        let size = self.bounds.size
        
        // Initialize a full size image. Opaque because we don't need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context?.fill(self.bounds)
        
        if let buffer = buffer {
            buffer.draw(in: self.bounds)
        }
        
        code(context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
