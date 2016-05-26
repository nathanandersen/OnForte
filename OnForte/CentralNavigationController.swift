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

/**
 CentralNavigationController is the backbone UINavigationController for the entire application.
 */
class CentralNavigationController: UINavigationController, UINavigationControllerDelegate {

//    let playlistController: PlaylistDrawerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistDrawerController") as! PlaylistDrawerController
    let playlistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistViewController") as! PlaylistViewController

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
    }

    /**
     Initialize the right button view, where the profile/leave profile buttons will be
    */
    private func renderRightButtonView() {
        rightButtonView = UIView()

        self.view.addSubview(rightButtonView)
        rightButtonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: rightButtonView, attribute: .Right, relatedBy: .Equal, toItem: self.navigationBar, attribute: .Right, multiplier: 1, constant: -1 * Style.menuButtonInset).active = true
        NSLayoutConstraint(item: rightButtonView, attribute: .Height, relatedBy: .Equal, toItem: rightButtonView, attribute: .Width, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: rightButtonView, attribute: .Top, relatedBy: .Equal, toItem: self.navigationBar, attribute: .Top, multiplier: 1, constant: 5).active = true
        NSLayoutConstraint(item: rightButtonView, attribute: .Bottom, relatedBy: .Equal, toItem: self.navigationBar, attribute: .Bottom, multiplier: 1, constant: -5).active = true

        rightButtonView.updateConstraints()
    }

    /**
    Initialize the profile button
    */
    private func renderProfileButton() {
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

    /**
     Initialize the leave profile button
    */
    private func renderLeaveProfileButton() {
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

    /**
     Add the activity indicator
    */
    private func renderActivityIndicator(){
        self.view.addSubview(activityIndicator)
    }

    /**
     Render the logo and add its constraints
    */
    private func renderLogo() {
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

    /**
     Push the playlist view controller
    */
    func presentPlaylist() {
        dispatch_async(dispatch_get_main_queue(), {
            self.pushViewController(self.playlistController, animated: true)
/*            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // completion block
                self.playlistController.updatePlaylistViewController()
                self.showProfileButton()
            })*/
        })
//        activityIndicator.showComplete("")
    }

    /**
     Push the profile view controller, and hide the profile button
    */
    func presentProfile() {
        CATransaction.begin()
        self.pushViewController(profileController, animated: true)
        CATransaction.setCompletionBlock({
            self.profileController.updateProfileDisplay()
            self.showLeaveProfileButton()
        })
        CATransaction.commit()
    }
    /**
     Display the profile button
    */
    private func showProfileButton() {
        self.rightButtonView.subviews.forEach({$0.removeFromSuperview()})
        rightButtonView.addSubview(profileButton)
        profileButtonConstraints.forEach({$0.active = true})
        profileButton.updateConstraints()
    }

    /**
     Show the leave profile button
    */
    private func showLeaveProfileButton() {
        self.rightButtonView.subviews.forEach({$0.removeFromSuperview()})
        rightButtonView.addSubview(leaveProfileButton)
        leaveProfileButtonConstraints.forEach({$0.active = true})
        leaveProfileButton.updateConstraints()
    }

    /**
     Hide the profile button
    */
    private func hideProfileButton() {
        self.rightButtonView.subviews.forEach({$0.removeFromSuperview()})
    }

    /**
     Leave the profile (by popping the profile view controller which is active), and
     then re-display the profile button
    */
    func leaveProfile() {
        self.popViewControllerAnimated(true)
        showProfileButton()
    }

    /**
     Leave the playlist (by popping the active view controller)
     */
    func leavePlaylist() {
        self.popViewControllerAnimated(true)
        hideProfileButton()
//        PlaylistHandler.leavePlaylist()
//        SongHandler.clearForNewPlaylist()
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


/**
 The animator for the push animation of CentralNavigationController
 */
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
/**
 The animator for the pop animation of CentralNavigationController
 */
class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
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
