//
//  FastForwardButton.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

/**
 A circular fast-forward button, with a blurred background.
 
 */
class FastForwardButton: UIButton {

    private let kInnerRadiusScaleFactor = CGFloat(0.05)
    private let kDefaultFFColor           = Style.darkGrayColor
    private var ffShapeLayer: CAShapeLayer = CAShapeLayer()

    override func drawRect(rect: CGRect) {

        let playPath = drawFastForwardIcon(rect)

        ffShapeLayer.path = playPath.CGPath
        ffShapeLayer.strokeColor = kDefaultFFColor.CGColor
        ffShapeLayer.fillColor = kDefaultFFColor.CGColor
        self.layer.addSublayer(ffShapeLayer)

        // draw a circle
        func d2R(degrees: CGFloat) -> CGFloat {
            return degrees * 0.0174532925 // 1 degree ~ 0.0174532925 radians
        }

        let arcWidth = (CGRectGetWidth(rect) * kInnerRadiusScaleFactor) / 2
        let radius = (CGRectGetMidY(rect) - arcWidth/2)

        func progressArc() -> CGPath {
            return UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)), radius: radius, startAngle: d2R(270), endAngle: d2R(269.99), clockwise: true).CGPath
        }

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        blurView.frame = rect
        blurView.userInteractionEnabled = false
        self.addSubview(blurView)
        self.sendSubviewToBack(blurView)

        let maskForPath = CAShapeLayer()
        maskForPath.path = progressArc()
        self.layer.mask = maskForPath
    }


    /**
     Draw the two-triangle fast forward icon using a Bezier Path.
     
     - parameters:
        - rect: The CGRect in which to draw the icon.
     - returns: The fast forward icon
    */
    func drawFastForwardIcon(rect: CGRect) -> UIBezierPath {
        let totalWidth: CGFloat = 0.35
        let singleTriangleWidth = totalWidth / 2
        let heightProportion: CGFloat = 0.17

        let midY = CGRectGetMidY(rect)
        let midX = CGRectGetMidX(rect)

        let leftX = CGRectGetWidth(rect) * (0.5 - singleTriangleWidth)
        let rightX = CGRectGetWidth(rect) * (0.5 + singleTriangleWidth)
        let bottomY = (midY - CGRectGetHeight(rect) * heightProportion)
        let topY = (midY + CGRectGetHeight(rect) * heightProportion)

        let path = UIBezierPath()
        path.lineJoinStyle = CGLineJoin.Round
        path.moveToPoint(CGPointMake(leftX, midY))

        path.addLineToPoint(CGPointMake(leftX, bottomY))
        path.addLineToPoint(CGPointMake(midX, midY))
        path.addLineToPoint(CGPointMake(leftX, topY))
        path.addLineToPoint(CGPointMake(leftX, midY))
        path.closePath()

        path.moveToPoint(CGPointMake(midX, midY))
        path.addLineToPoint(CGPointMake(midX, bottomY))
        path.addLineToPoint(CGPointMake(rightX, midY))
        path.addLineToPoint(CGPointMake(midX, topY))
        path.addLineToPoint(CGPointMake(midX, midY))
        path.closePath()
        return path
    }


}