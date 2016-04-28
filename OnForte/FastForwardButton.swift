//
//  FastForwardButton.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/28/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

private let darkGray = UIColor(
    red: 147.0 / 255.0,
    green: 149.0 / 255.0,
    blue: 152.0 / 250.0,
    alpha: 1
)

func drawFastForward(rect: CGRect) -> UIBezierPath {
    let totalWidth: CGFloat = 0.35
    let singleTriangleWidth = totalWidth / 2
    let heightProportion: CGFloat = 0.17

    let width = CGRectGetWidth(rect)

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

    /*
    let midY = CGRectGetMidY(rect)

    let leftX = CGRectGetWidth(rect) * 0.4107

    let path = UIBezierPath()
    path.lineJoinStyle = CGLineJoin.Round
    path.moveToPoint(CGPointMake(leftX, midY))
    path.addLineToPoint(CGPointMake(leftX, (midY - CGRectGetHeight(rect) * 0.17)))
    path.addLineToPoint(CGPointMake(leftX + (CGRectGetWidth(rect) * 0.2322), midY))
    path.addLineToPoint(CGPointMake(leftX, (midY + CGRectGetHeight(rect) * 0.17)))
    path.addLineToPoint(CGPointMake(leftX, midY))
*/
    return path
}

class FastForwardButton: UIButton {

    private let kInnerRadiusScaleFactor = CGFloat(0.05)
    private let kDefaultFFColor           = darkGray
    private var ffShapeLayer: CAShapeLayer = CAShapeLayer()
    
    override func drawRect(rect: CGRect) {

        // figure out how this actually draws the shenanigans
//        let midY = CGRectGetMidY(rect)
//        let playLeftX = CGRectGetWidth(rect) * 0.4107

        let playPath = drawFastForward(rect)
/*        let playPath = UIBezierPath()
        playPath.lineJoinStyle = CGLineJoin.Round
        playPath.moveToPoint(CGPointMake(playLeftX, midY))
        playPath.addLineToPoint(CGPointMake(playLeftX, (midY - CGRectGetHeight(rect) * 0.17)))
        playPath.addLineToPoint(CGPointMake(playLeftX + (CGRectGetWidth(rect) * 0.2322), midY))
        playPath.addLineToPoint(CGPointMake(playLeftX, (midY + CGRectGetHeight(rect) * 0.17)))
        playPath.addLineToPoint(CGPointMake(playLeftX, midY))*/

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
        // this masks the background of the progress bar circle
        // (sets everything else to be transparent)

        // add the image to the view
    }

}