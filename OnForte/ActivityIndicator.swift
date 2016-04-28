//
//  ActivityIndicator.swift
//  Forte
//
//  Created by Noah Grumman on 4/8/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

/**
 This is an extension of the NVActivityIndicatorView pod.
 */
class ActivityIndicator: UIView {
    
    var activityIndicator: NVActivityIndicatorView!
    var completeIndicator: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        renderActivityIndicator()
        renderCompleteIndicator()
        renderLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Render the 'complete' indicator
     */
    private func renderCompleteIndicator() {
        completeIndicator = UIImageView(frame: CGRectMake(10, 5, 20, 20))
        completeIndicator.image = UIImage(named: "check")
        completeIndicator.tintColor = Style.primaryColor
        self.addSubview(completeIndicator)
    }

    /**
     Render the normal activity indicator
    */
    private func renderActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40), type: NVActivityIndicatorType.LineScaleParty, color: Style.primaryColor, padding: CGFloat(15))
        self.addSubview(activityIndicator)
    }

    /**
    Render the label
    */
    private func renderLabel(){
        label = UILabel(frame: CGRectMake(0, 28, 40, 10))
        label.text = ""
        label.textColor = Style.primaryColor
        label.textAlignment = .Center
        label.font = Style.defaultFont(7)
        self.addSubview(label)
    }

    /**
     Display some activity with a label caption
    */
    internal func showActivity(text: String){
        completeIndicator.hidden = true
        activityIndicator.hidden = false
        label.hidden = false
        label.text = text
        activityIndicator.startAnimation()
    }

    /**
     Show 'complete' status
    */
    internal func showComplete(text: String){
        activityIndicator.stopAnimation()
        activityIndicator.hidden = true
        completeIndicator.hidden = false
        label.hidden = false
        label.text = text
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ActivityIndicator.hideAll), userInfo: nil, repeats: false)
    }

    /**
    Hide the activity indicator
    */
    func hideAll(){
        activityIndicator.hidden = true
        completeIndicator.hidden = true
        label.hidden = true
    }
}