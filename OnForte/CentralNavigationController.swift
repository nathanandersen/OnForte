//
//  CentralNavigationController.swift
//  OnForte
//
//  Created by Nathan Andersen on 4/14/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation
import UIKit

var centralNavigationController: CentralNavigationController!

class CentralNavigationController: UINavigationController/*, UINavigationControllerDelegate*/ {

    override func viewDidLoad() {
        super.viewDidLoad()
        centralNavigationController = self
        //        self.delegate = self
        renderActivityIndicator()
        renderLogo()
    }

    func renderActivityIndicator(){
        self.view.addSubview(activityIndicator)
    }

    func renderLogo() {
        let label = UILabel()
        label.font = Style.logoFont
        label.text = "forte"
        label.textAlignment = .Center
        self.navigationBar.addSubview(label)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CentralNavigationController.presentProfile))
        tapGestureRecognizer.numberOfTapsRequired = 1
        label.userInteractionEnabled = true
        label.addGestureRecognizer(tapGestureRecognizer)

        let centerConstraint = NSLayoutConstraint(item: label,
                                                  attribute: .CenterX,
                                                  relatedBy: .Equal,
                                                  toItem: self.navigationBar,
                                                  attribute: .CenterX,
                                                  multiplier: 1,
                                                  constant: 0.0)
        let topMarginConstraint = NSLayoutConstraint(item: label,
                                                     attribute: .Top,
                                                     relatedBy: .Equal,
                                                     toItem: self.navigationBar,
                                                     attribute: .Top,
                                                     multiplier: 1,
                                                     constant: 5)
        let bottomMarginConstraint = NSLayoutConstraint(item: label,
                                                        attribute: .Bottom,
                                                        relatedBy: .Equal,
                                                        toItem: self.navigationBar,
                                                        attribute: .Bottom,
                                                        multiplier: 1,
                                                        constant: -5)
        let proportionConstraint = NSLayoutConstraint(item: label,
                                                      attribute: .Width,
                                                      relatedBy: .Equal, toItem: nil,
                                                      attribute: .NotAnAttribute,
                                                      multiplier: 1,
                                                      constant: 100.0)
        let constraints = [centerConstraint,topMarginConstraint,bottomMarginConstraint,proportionConstraint]
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }

    func presentPlaylist() {
        self.popViewControllerAnimated(true)
        self.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistDrawerController"), animated: true)
    }

    func presentProfile() {
        self.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController"), animated: true)
    }

    func leavePlaylist() {
        self.popViewControllerAnimated(true)
        self.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RootViewController"), animated: true)
    }
    
}
