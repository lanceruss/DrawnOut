//
//  LineSegment.swift
//  Fictionary
//
//  Created by Lance Russ on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

struct LineSegment {
    var firstPoint: CGPoint?
    var secondPoint: CGPoint?
}

func lineSegmentPerpendicularTo(_ pp: LineSegment, ofRelativeLength fraction: Float) -> LineSegment {
    let x0: CGFloat = pp.firstPoint!.x
    let y0: CGFloat = pp.firstPoint!.y
    let x1: CGFloat = pp.secondPoint!.x
    let y1: CGFloat = pp.secondPoint!.y
    var dx: CGFloat
    var dy: CGFloat
    dx = x1 - x0
    dy = y1 - y0
    var xa: CGFloat
    var ya: CGFloat
    var xb: CGFloat
    var yb: CGFloat
    let fractionCG = CGFloat(fraction) // a conversion
    xa = x1 + fractionCG / 2 * dy
    ya = y1 - fractionCG / 2 * dx
    xb = x1 - fractionCG / 2 * dy
    yb = y1 + fractionCG / 2 * dx
    
    return LineSegment(firstPoint: CGPoint(x: xa, y: ya), secondPoint: CGPoint(x: xb, y: yb))
}

func len_sq(_ p1: CGPoint, p2: CGPoint) -> CGFloat {
    
    let dx: CGFloat = p2.x - p1.x
    let dy: CGFloat = p2.y - p1.y
    return dx * dx + dy * dy
    
}

func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
    
    if (value < min) {
        return min
    }
    
    if (value > max) {
        return max
    }
    
    return value
}
