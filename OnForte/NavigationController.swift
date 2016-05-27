//
//  NavigationController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Forte Labs. All rights reserved.
//

import Foundation

//var appNavigationController: NavigationController!

/**
 This is a UIViewController that never displays a back button. Simple extension,
 written to pair with the custom NavigationController.
 */
class DefaultViewController: UIViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "onforte"
    }
}

class NavigationController: UINavigationController {
    private let playlistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistViewController") as! PlaylistViewController
    private let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController

    internal func pushSettings() {
        self.pushViewController(settingsController, animated: true)
    }

    internal func pushPlaylist() {
        self.pushViewController(playlistController, animated: true)
    }

    internal func popSettings() {
        self.popViewControllerAnimated(true)
        // do some other things
    }

    internal func popPlaylist() {
        self.popViewControllerAnimated(true)
        // do some other things
    }


}


/**
 Implementation of custom animations.
 */
extension NavigationController: UINavigationControllerDelegate {

    override func viewDidAppear(animated: Bool) {
        delegate = self
//        navigationItem.title = "onforte"
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
