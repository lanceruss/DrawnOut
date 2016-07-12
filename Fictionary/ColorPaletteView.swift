//
//  ColorPaletteView.swift
//  Fictionary
//
//  Created by Lance Russ on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

protocol ColorPaletteViewDelegate {
    func didTapView(view: ColorPaletteView)
}

class ColorPaletteView: UIView, UIGestureRecognizerDelegate {

    var tapRecognizer4: UITapGestureRecognizer?
    
    var delegate: ColorPaletteViewDelegate?
    
    func setupGestureRecognizersInView(view: UIView) {
        
        tapRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(ColorPaletteView.handlePaletteTap(_:)))
        view.addGestureRecognizer(tapRecognizer4!)
    }

    @objc private func handlePaletteTap(sender: UITapGestureRecognizer) {
        
        let point = sender.locationInView(sender.view)
        
        if sender.state == .Ended {
            self.tapAtPalettePoint(point)
        }
    }
    
    private func tapAtPalettePoint(point: CGPoint) {
        print("tapPalette")
        delegate?.didTapView(self)
    }
    
    /*
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view?.isDescendantOfView(self) == true {
            return true
        }
        return false
    }
    */
}
