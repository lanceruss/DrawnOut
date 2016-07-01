//
//  FreehandDrawController.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class FreehandDrawController: NSObject {
    
    private var commandQueue: Array<DrawCommand> = []
    private var lastPoint: CGPoint = CGPointZero
    private let canvas: protocol<Canvas, DrawCommandReceiver>
    private var lineStrokeCommand: ComposedCommand?
    private var lastSegment: Segment?
    private var lastVelocity: CGPoint = CGPointZero
    private var lastWidth: CGFloat?
    
    var color: UIColor = UIColor.blackColor()
    var width: CGFloat = 3.2
    
    required init(canvas: protocol<Canvas, DrawCommandReceiver>, view: UIView) {
        
        self.canvas = canvas
        super.init()
        
        self.setUpGestureRecognizersInView(view)
    }
    
    private func setUpGestureRecognizersInView(view: UIView) {
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(FreehandDrawController.handlePan(_:)))
        view.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FreehandDrawController.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FreehandDrawController.handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTouchesRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        
        let point = sender.locationInView(sender.view)
        
        switch sender.state {
        case .Began:
            self.startAtPoint(point)
        case .Changed:
            self.continueAtPoint(point, velocity: sender.velocityInView(sender.view))
        case .Ended:
            self.endAtPoint(point)
        case .Failed:
            self.endAtPoint(point)
        default:
            assert(false, "State not handled")
        }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        
        let point = sender.locationInView(sender.view)
        if sender.state == .Ended {
            self.tapAtPoint(point)
        }
    }
    
    @objc private func handleDoubleTap(sender: UITapGestureRecognizer) {
        undo()
    }
    
    func gestureRecognizer(handleTap: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer handleDoubleTap: UIGestureRecognizer) -> Bool {
        return false
    }
    
    private func startAtPoint(point: CGPoint) {
        
        self.lastPoint = point
        self.lineStrokeCommand = ComposedCommand(commands: [])
    }
    
    private func continueAtPoint(point: CGPoint, velocity: CGPoint) {
        
        let segmentWidth = modulatedWidth(self.width, velocity: velocity, previousVelocity: self.lastVelocity, previousWidth: self.lastWidth ?? self.width)
        let segment = Segment(a: self.lastPoint, b: point, width: segmentWidth)
        let lineCommand = LineDrawCommand(current: segment, previous: lastSegment, width: segmentWidth, color: self.color)
        
        self.canvas.executeCommands([lineCommand])
        
        self.lineStrokeCommand?.addCommand(lineCommand)
        self.lastPoint = point
        self.lastSegment = segment
        self.lastVelocity = velocity
        self.lastWidth = segmentWidth
    }
    
    private func endAtPoint(point: CGPoint) {
        
        if let lineStrokeCommand = self.lineStrokeCommand {
            self.commandQueue.append(lineStrokeCommand)
        }
        
        self.lastPoint = CGPointZero
        self.lastSegment = nil
        self.lineStrokeCommand = nil
        self.lastVelocity = CGPointZero
        self.lastWidth = nil
    }
    
    private func tapAtPoint(point: CGPoint) {
        
        let circleCommand = CircleDrawCommand(center: point, radius: self.width/2.0, color: self.color)
        self.canvas.executeCommands([circleCommand])
        self.commandQueue.append(circleCommand)
    }
    
    func undo() {
        
        if self.commandQueue.count > 0 {
            self.commandQueue.removeLast()
            self.canvas.reset()
            self.canvas.executeCommands(self.commandQueue)
        }
    }
    
    
    
    
    

}
