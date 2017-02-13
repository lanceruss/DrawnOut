//
//  DrawingView.swift
//  Fictionary
//
//  Created by Lance Russ on 7/10/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

class DrawingView: UIView, UIGestureRecognizerDelegate {
    
    var firstChange: Bool = true
    
    let CAPACITY = 100
    let FF: Float = 0.2
    let LOWER: Float = 0.01
    let UPPER: Float = 1.0
    
    var incrementalImage: UIImage?
    var pts: [CGPoint] = []
    var ctr: Int = 0
    var pointsBuffer: [CGPoint] = []
    var bufIdx: Int = 0
    var drawingQueue: DispatchQueue?
    var isFirstTouchPoint: Bool?
    var lastSegmentOfPrevious: LineSegment?
    
    var color: UIColor? = UIColor.black
    
    var didHit40: Bool? = false
    
    var imageHistory: Array<UIImage> = []
    
    func setupGestureRecognizersInView(_ view: UIView) {
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawingView.handlePan(_:)))
        view.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawingView.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawingView.handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTouchesRequired = 2
        view.addGestureRecognizer(doubleTapRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //print("shouldRecieveTouch")
        if touch.view == gestureRecognizer.view {
            //print("true")
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ handleTap: UIGestureRecognizer,shouldRecognizeSimultaneouslyWith handleDoubleTap: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func draw(_ rect: CGRect) {
        
        incrementalImage?.draw(in: rect)
    }
    
    @objc fileprivate func handleTap(_ sender: UITapGestureRecognizer) {
        //print("DrawingViewTap")
        let point = sender.location(in: sender.view)
        
        if sender.state == .ended {
            
            self.tapAtPoint(point)
        }
    }
    
    fileprivate func tapAtPoint(_ point: CGPoint) {
        
        let radius: CGFloat = 4.2
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        
        if self.incrementalImage == nil {
            
            let rectpath: UIBezierPath = UIBezierPath(rect: self.bounds)
            UIColor.white.setFill()
            rectpath.fill()
        }
        
        let dotpath: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: radius, height: radius))
        
        self.incrementalImage?.draw(at: CGPoint.zero)
        self.color!.setStroke()
        self.color!.setFill()
        dotpath.fill()
        dotpath.stroke()
        
        self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setNeedsDisplay()
        if imageHistory.count > 40 {
            imageHistory.remove(at: 0)
            didHit40 = true
            print(imageHistory.count)
        }
        imageHistory.append(incrementalImage!) // full line
    }
    
    @objc fileprivate func handlePan(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.location(in: sender.view)
        switch sender.state {
        case .began:
            self.startAtPoint(point)
        case .changed:
            self.continueAtPoint(point)
        case .ended:
            self.endAtPoint(point)
        case .failed:
            self.endAtPoint(point)
        default:
            self.endAtPoint(point)
            //            assert(false, "State not handled")
        }
    }
    
    fileprivate func startAtPoint(_ point: CGPoint) {
        
        ctr = 0
        bufIdx = 0;
        pts.insert(point, at: 0)
        isFirstTouchPoint = true
        firstChange = true
    }
    
    fileprivate func continueAtPoint(_ point: CGPoint) {
        if firstChange == true {
            firstChange = false
        } else {
            
            let p: CGPoint = point
            
            ctr += 1
            
            pts.insert(p, at: ctr)
            
            if ctr == 4 {
                pts[3] = CGPoint(x: (pts[2].x + pts[4].x) / 2.0, y: (pts[2].y + pts[4].y) / 2.0)
                
                for i in 0 ..< 4 {
                    pointsBuffer.insert(pts[i], at: bufIdx + i)
                }
                bufIdx += 4
                
                let bounds: CGRect = self.bounds
                
                drawingQueue!.async(execute: {
                    
                    //offset path is each new path.
                    let offsetPath: UIBezierPath = UIBezierPath()
                    
                    if self.bufIdx == 0 { return }
                    
                    var ls: [LineSegment]? = []
                    
                    //                    for i in 0 ..< self.bufIdx {
                    //var i = 0
                    for i in 0..<self.bufIdx {
                       // i += 4
                        if (i == 0) ||  ((i % 4) == 0) {
                    //}
                    //for var i = 0; i < self.bufIdx; i += 4 {
                        
                        if self.isFirstTouchPoint == true {
                            
                            let newLineSegment = LineSegment(firstPoint: self.pointsBuffer[0], secondPoint: self.pointsBuffer[0])
                            
                            ls!.insert(newLineSegment, at: 0)
                            
                            offsetPath.move(to: ls![0].firstPoint!)
                            self.isFirstTouchPoint = false
                            
                        } else {
                            
                            ls!.insert(self.lastSegmentOfPrevious!, at: 0)
                            
                        }
                        
                        let CGFF = CGFloat(self.FF)
                        let CGLOWER = CGFloat(self.LOWER)
                        let CGUPPER = CGFloat(self.UPPER)
                        
                        let frac1: CGFloat = CGFF/clamp(len_sq(self.pointsBuffer[i], p2: self.pointsBuffer[i+1]), min: CGLOWER, max: CGUPPER)
                        let frac2: CGFloat = CGFF/clamp(len_sq(self.pointsBuffer[i+1], p2: self.pointsBuffer[i+2]), min: CGLOWER, max: CGUPPER)
                        let frac3: CGFloat = CGFF/clamp(len_sq(self.pointsBuffer[i+2], p2: self.pointsBuffer[i+3]), min: CGLOWER, max: CGUPPER)
                        
                        let frac1F = Float(frac1)
                        let frac2F = Float(frac2)
                        let frac3F = Float(frac3)
                        
                        // calculate the offset line segment.
                        ls!.insert(lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i], secondPoint: self.pointsBuffer[i+1]), ofRelativeLength: frac1F), at: 1)
                        ls!.insert(lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i+1], secondPoint: self.pointsBuffer[i+2]), ofRelativeLength: frac2F), at: 2)
                        ls!.insert(lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i+2], secondPoint: self.pointsBuffer[i+3]), ofRelativeLength: frac3F), at: 3)
                        
                        // constructs the drawn line, made up of two subpaths
                        offsetPath.move(to: ls![0].firstPoint!)
                        offsetPath.addCurve(to: ls![3].firstPoint!, controlPoint1: ls![1].firstPoint!, controlPoint2: ls![2].firstPoint!)
                        offsetPath.addLine(to: ls![3].secondPoint!)
                        offsetPath.addCurve(to: ls![0].secondPoint!, controlPoint1: ls![2].secondPoint!, controlPoint2: ls![1].secondPoint!)
                        offsetPath.close()
                        
                        self.lastSegmentOfPrevious = ls![3] // makes sure that the paths line up with what came before.
                    }
                    } // ???????????????
                    
                    UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
                    
                    if self.incrementalImage == nil {
                        
                        let rectpath: UIBezierPath = UIBezierPath(rect: self.bounds)
                        UIColor.white.setFill()
                        rectpath.fill()
                    }
                    
                    self.incrementalImage?.draw(at: CGPoint.zero)
                    self.color!.setStroke()
                    self.color!.setFill()
                    offsetPath.fill()
                    offsetPath.stroke()
                    
                    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    offsetPath.removeAllPoints()
                    DispatchQueue.main.async(execute: {
                        self.bufIdx = 0
                        self.setNeedsDisplay()
                    })
                    
                })
                
                pts[0] = pts[3]
                pts[1] = pts[4]
                ctr = 1
            }
        }
    }
    
    fileprivate func endAtPoint(_ point: CGPoint) {
        
        setNeedsDisplay()
        if incrementalImage != nil {
            if imageHistory.count > 40 {
                imageHistory.remove(at: 0)
                didHit40 = true
                print(imageHistory.count)
            }
            imageHistory.append(incrementalImage!) // full line
        }
        
    }
    
    @objc fileprivate func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        
        if imageHistory.count > 0 {
            if didHit40 == true && imageHistory.count > 1 {
                
                imageHistory.removeLast()
                if imageHistory.count == 0 {
                    
                    incrementalImage = nil
                    
                    setNeedsDisplay()
                    
                    if incrementalImage == nil {
                        UIGraphicsBeginImageContext(self.bounds.size)
                        self.layer.render(in: UIGraphicsGetCurrentContext()!)
                        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                    }
                    
                } else  {
                    incrementalImage = imageHistory.last
                    setNeedsDisplay()
                }
            } else if didHit40 == false {
                
                imageHistory.removeLast()
                if imageHistory.count == 0 {
                    
                    incrementalImage = nil
                    
                    setNeedsDisplay()
                    
                    if incrementalImage == nil {
                        UIGraphicsBeginImageContext(self.bounds.size)
                        self.layer.render(in: UIGraphicsGetCurrentContext()!)
                        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                    }
                    
                } else  {
                    incrementalImage = imageHistory.last
                    setNeedsDisplay()

            }
        }
        }
    }
    
    
    
    
}
