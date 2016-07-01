//
//  Segment.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

struct Segment {
    
    let a: CGPoint
    let b: CGPoint
    let width: CGFloat
    
    var midPoint: CGPoint {
        return CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}
