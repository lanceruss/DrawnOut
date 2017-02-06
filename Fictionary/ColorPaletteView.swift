//
//  ColorPaletteView.swift
//  Fictionary
//
//  Created by Lance Russ on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

protocol ColorPaletteViewDelegate {
    func didTapView(_ view: ColorPaletteView)
}

class ColorPaletteView: UIView, UIGestureRecognizerDelegate {

    var tapRecognizer4: UITapGestureRecognizer?
    
    var delegate: ColorPaletteViewDelegate?
    
    func setupGestureRecognizersInView(_ view: UIView) {
        
        tapRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(ColorPaletteView.handlePaletteTap(_:)))
        view.addGestureRecognizer(tapRecognizer4!)
    }

    @objc fileprivate func handlePaletteTap(_ sender: UITapGestureRecognizer) {
        
        let point = sender.location(in: sender.view)
        
        if sender.state == .ended {
            self.tapAtPalettePoint(point)
        }
    }
    
    fileprivate func tapAtPalettePoint(_ point: CGPoint) {
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
