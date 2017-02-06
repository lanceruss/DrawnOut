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
    
    case lightRed
    case red
    case darkRed
    case orange
    case lightOrange
    case lightYellow
    case grass
    case lightGreen
    case darkGreen
    case limeGreen
    case lightAqua
    case lightBlue
    case blue
    case lightViolet
    case violet
    case darkPink
    case lightPink
    case white
    case lightGrey
    case grey
    case darkGrey
    case black
    
    
    func color() -> UIColor {
        switch self {
            
        case .lightRed: return UIColor(red:0.93, green:0.47, blue:0.47, alpha:1.00)
        case .red: return UIColor(red:0.95, green:0.28, blue:0.28, alpha:1.00)
        case .darkRed: return UIColor(red:0.76, green:0.18, blue:0.18, alpha:1.00)
        case .orange: return UIColor(red:1.00, green:0.61, blue:0.17, alpha:1.00)
        case .lightOrange: return UIColor(red:1.00, green:0.77, blue:0.35, alpha:1.00)
        case .lightYellow: return UIColor(red:1.00, green:1.00, blue:0.35, alpha:1.00)
        case .grass: return UIColor(red:0.71, green:0.89, blue:0.28, alpha:1.00)
        case .lightGreen: return UIColor(red:0.29, green:0.75, blue:0.27, alpha:1.00)
        case .darkGreen: return UIColor(red:0.16, green:0.58, blue:0.14, alpha:1.00)
        case .limeGreen: return UIColor(red:0.49, green:0.93, blue:0.47, alpha:1.00)
        case .lightAqua: return UIColor(red:0.62, green:0.97, blue:0.97, alpha:1.00)
        case .lightBlue: return UIColor(red:0.35, green:0.64, blue:0.91, alpha:1.00)
        case .blue: return UIColor(red:0.28, green:0.29, blue:0.81, alpha:1.00)
        case .lightViolet: return UIColor(red:0.75, green:0.47, blue:0.93, alpha:1.00)
        case .violet: return UIColor(red:0.51, green:0.16, blue:0.73, alpha:1.00)
        case .darkPink: return UIColor(red:0.86, green:0.37, blue:0.62, alpha:1.00)
        case .lightPink: return UIColor(red:1.00, green:0.69, blue:0.81, alpha:1.00)
        case .white: return UIColor.white
        case .lightGrey: return UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.00)
        case .grey: return UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
        case .darkGrey: return UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.00)
        case .black: return UIColor.black
            
        }
    }

    
}
