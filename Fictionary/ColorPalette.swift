//
//  ColorPalette.swift
//  Fictionary
//
//  Created by Lance Russ on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import Foundation
import UIKit

enum ColorPalette: Int {
    
    case LightRed
    case Red
    case DarkRed
    case Orange
    case LightOrange
    case LightYellow
    case Grass
    case LightGreen
    case DarkGreen
    case LimeGreen
    case LightAqua
    case LightBlue
    case Blue
    case LightViolet
    case Violet
    case DarkPink
    case LightPink
    case White
    case LightGrey
    case Grey
    case DarkGrey
    case Black
    
    
    func color() -> UIColor {
        switch self {
            
        case .LightRed: return UIColor(red:0.93, green:0.47, blue:0.47, alpha:1.00)
        case .Red: return UIColor(red:0.95, green:0.28, blue:0.28, alpha:1.00)
        case .DarkRed: return UIColor(red:0.76, green:0.18, blue:0.18, alpha:1.00)
        case .Orange: return UIColor(red:1.00, green:0.61, blue:0.17, alpha:1.00)
        case .LightOrange: return UIColor(red:1.00, green:0.77, blue:0.35, alpha:1.00)
        case .LightYellow: return UIColor(red:1.00, green:1.00, blue:0.35, alpha:1.00)
        case .Grass: return UIColor(red:0.71, green:0.89, blue:0.28, alpha:1.00)
        case .LightGreen: return UIColor(red:0.29, green:0.75, blue:0.27, alpha:1.00)
        case .DarkGreen: return UIColor(red:0.16, green:0.58, blue:0.14, alpha:1.00)
        case .LimeGreen: return UIColor(red:0.49, green:0.93, blue:0.47, alpha:1.00)
        case .LightAqua: return UIColor(red:0.62, green:0.97, blue:0.97, alpha:1.00)
        case .LightBlue: return UIColor(red:0.35, green:0.64, blue:0.91, alpha:1.00)
        case .Blue: return UIColor(red:0.28, green:0.29, blue:0.81, alpha:1.00)
        case .LightViolet: return UIColor(red:0.75, green:0.47, blue:0.93, alpha:1.00)
        case .Violet: return UIColor(red:0.51, green:0.16, blue:0.73, alpha:1.00)
        case .DarkPink: return UIColor(red:0.86, green:0.37, blue:0.62, alpha:1.00)
        case .LightPink: return UIColor(red:1.00, green:0.69, blue:0.81, alpha:1.00)
        case .White: return UIColor.whiteColor()
        case .LightGrey: return UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00)
        case .Grey: return UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
        case .DarkGrey: return UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.00)
        case .Black: return UIColor.blackColor()
            
        }
    }

    
}
