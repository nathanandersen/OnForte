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

class CentralNavigationController: UINavigationController, UINavigationControllerDelegate {

//    let rootController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RootViewController")
    let playlistController: PlaylistDrawerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistDrawerController") as! PlaylistDrawerController
    let profileController: ProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController

    var profileButton: UIButton!
    var profileButtonConstraints: [NSLayoutConstraint]!
    var leaveProfileButton: UIButton!
    var leaveProfileButtonConstraints: [NSLayoutConstraint]!
    var rightButtonView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralNavigationController = self
        self.delegate = self
        renderActivityIndicator()
        renderLogo()
        renderRightButtonView()
        renderProfileButton()
        renderLeaveProfileButton()
        self.navigationItem.setHidesBackButton(true, animated: true)
        showProfileButton()
    }

    func renderRightButtonView() {
        rightButtonView = UIView()

        self.view.addSubview(rightButtonView)
        rightButtonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: rightButtonView, attribute: .Right, relatedBy: .Equal, toItem: self.navigationBar, attribute: .Right, multiplier: 1, constant: -20).active = true
        NSLayoutConstraint(item: rightButtonView, attribute: .Height, relatedBy: .Equal, toItem: rightButtonView, attribute: .Width, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: rightButtonView, attribute: .Top, relatedBy: .Equal, toItem: self.navigationBar, attribute: .Top, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: rightButtonView, attribute: .Bottom, relatedBy: .Equal, toItem: self.navigationBar, attribute: .Bottom, multiplier: 1, constant: -5).active = true

        rightButtonView.updateConstraints()
    }

    func renderProfileButton() {
        profileButton = Style.iconButton()
        profileButton.setImage(UIImage(named: "profile")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        profileButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        profileButton.addTarget(self, action: #selector(CentralNavigationController.presentProfile), forControlEvents: .TouchUpInside)
        profileButton.translatesAutoresizingMaskIntoConstraints = false

        let leftConstraint = NSLayoutConstraint(item: profileButton, attribute: .Left, relatedBy: .Equal, toItem: rightButtonView, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: profileButton, attribute: .Right, relatedBy: .Equal, toItem: rightButtonView, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: profileButton, attribute: .Top, relatedBy: .Equal, toItem: rightButtonView, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: profileButton, attribute: .Bottom, relatedBy: .Equal, toItem: rightButtonView, attribute: .Bottom, multiplier: 1, constant: 0)

        profileButtonConstraints = [leftConstraint,rightConstraint,topConstraint,bottomConstraint]
    }

    func renderLeaveProfileButton() {
        leaveProfileButton = Style.iconButton()
        leaveProfileButton.setImage(UIImage(named: "delete")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        leaveProfileButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        leaveProfileButton.addTarget(self, action: #selector(CentralNavigationController.leaveProfile), forControlEvents: .TouchUpInside)

        leaveProfileButton.translatesAutoresizingMaskIntoConstraints = false

        let leftConstraint = NSLayoutConstraint(item: leaveProfileButton, attribute: .Left, relatedBy: .Equal, toItem: rightButtonView, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: leaveProfileButton, attribute: .Right, relatedBy: .Equal, toItem: rightButtonView, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: leaveProfileButton, attribute: .Top, relatedBy: .Equal, toItem: rightButtonView, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: leaveProfileButton, attribute: .Bottom, relatedBy: .Equal, toItem: rightButtonView, attribute: .Bottom, multiplier: 1, constant: 0)

        leaveProfileButtonConstraints = [leftConstraint,rightConstraint,topConstraint,bottomConstraint]
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
        dispatch_async(dispatch_get_main_queue(), {
            self.pushViewController(self.playlistController, animated: true)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // completion block
                self.playlistController.updatePlaylistViewController()
            })
        })
        activityIndicator.showComplete("")
    }

    func presentProfile() {
        profileController.updateProfileDisplay()
        self.pushViewController(profileController, animated: true)
        showLeaveProfileButton()
    }

    func showProfileButton() {
        self.rightButtonView.subviews.forEach({$0.removeFromSuperview()})
        rightButtonView.addSubview(profileButton)
        profileButtonConstraints.forEach({$0.active = true})
        profileButton.updateConstraints()
    }

    func showLeaveProfileButton() {
        self.rightButtonView.subviews.forEach({$0.removeFromSuperview()})
        rightButtonView.addSubview(leaveProfileButton)
        leaveProfileButtonConstraints.forEach({$0.active = true})
        leaveProfileButton.updateConstraints()

    }

    func leaveProfile() {
        self.popViewControllerAnimated(true)
        showProfileButton()
    }

    func leavePlaylist() {
        self.popViewControllerAnimated(true)
    }

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if operation == UINavigationControllerOperation.Push {
            return PushAnimator()
        }

        if operation == UINavigationControllerOperation.Pop {
            return PopAnimator()
        }
        return nil
    }
    
}


class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()!
        let bounds = UIScreen.mainScreen().bounds
        toViewController.view.frame = CGRectOffset(finalFrameForVC, 0, bounds.size.height)
        containerView.addSubview(toViewController.view)
//        fromViewController.view.alpha = 0
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            fromViewController.view.alpha = 0.5
            toViewController.view.frame = finalFrameForVC
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
                fromViewController.view.alpha = 1.0
        })
    }

    
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
        //        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // this code animates the TO view controller, from the bottom up.
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()!
        let bounds = UIScreen.mainScreen().bounds
        toViewController.view.frame = CGRectOffset(finalFrameForVC, 0, bounds.size.height)
        toViewController.view.frame = finalFrameForVC
        toViewController.view.alpha = 0

        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {

            toViewController.view.alpha = 1
            fromViewController.view.alpha = 0.5
            fromViewController.view.frame = CGRectOffset(finalFrameForVC, 0, bounds.size.height)
            toViewController.view.frame = finalFrameForVC
            }, completion: {
                finished in
                toViewController.view.alpha = 1
                transitionContext.completeTransition(true)
                fromViewController.view.alpha = 1.0
        })
    }
}
