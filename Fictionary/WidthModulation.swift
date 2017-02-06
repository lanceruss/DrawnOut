//
//  WidthModulation.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

func modulatedWidth(_ width: CGFloat, velocity: CGPoint, previousVelocity: CGPoint, previousWidth: CGFloat) -> CGFloat {
    
    let velocityAdjustment: CGFloat = 600.0
    let speed = velocity.length() / velocityAdjustment
    let previousSpeed = previousVelocity.length() / velocityAdjustment
    
    let modulated = width / (0.8 * speed + 0.6 * previousSpeed)
    let limited = clamp(modulated, min: 0.45 * previousWidth, max: 1.15 * previousWidth)
    let final = clamp(limited, min: 0.4 * width, max: 0.7 * width)
    
    return final
}

extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt((self.x * self.x) + (self.y * self.y))
    }
}


//func clamp<T: Comparable>(value: T, min: T, max: T) -> T {
//    
//    if (value < min) {
//        return min
//    }
//    
//    if (value > max) {
//        return max
//    }
//    
//    return value
//}
