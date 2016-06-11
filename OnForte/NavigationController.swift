//
//  NavigationController.swift
//  OnForte
//
//  Created by Nathan Andersen on 5/26/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation

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

let operationStartedKey = "operationStarted"
let operationFinishedKey = "operationFinished"

class NavigationController: UINavigationController {
    private let playlistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistTabBarController") as! PlaylistTabBarController
    private let settingsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController

    private var blinkingTimer: NSTimer!
    private var numOperationsRemaining = 0

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationController.startAsyncOperation), name: operationStartedKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigationController.asyncOperationComplete), name: operationFinishedKey, object: nil)
    }

    internal func pushSettings() {
        CATransaction.begin()
        self.pushViewController(settingsController, animated: true)
        CATransaction.setCompletionBlock({
            (PlaylistHandler.isHost()) ? self.settingsController.showSettings(.Host) : self.settingsController.showSettings(.Guest)
        })
        CATransaction.commit()
    }

    internal func startAsyncOperation() {
        if blinkingTimer == nil {
            blinkingTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NavigationController.blinkLabel), userInfo: nil, repeats: true)
        }
        numOperationsRemaining += 1

    }

    internal func asyncOperationComplete() {
        numOperationsRemaining -= 1
        if numOperationsRemaining == 0 {
            blinkingTimer.invalidate()
            blinkingTimer = nil
        }
    }

    internal func blinkLabel() {
        let view = self.navigationBar
        view.alpha = 0
        UIView.animateWithDuration(0.5, delay: 0, options: [.AllowUserInteraction, .Autoreverse], animations: {
            view.alpha = 1
            }, completion: nil)
    }

    internal func pushPlaylist() {
        dispatch_async(dispatch_get_main_queue(), {
            CATransaction.begin()
            self.pushViewController(self.playlistController, animated: true)
            CATransaction.setCompletionBlock({
                self.playlistController.presentNewPlaylist()
//                APIHandler.updateAPIInformation()
                NSNotificationCenter.defaultCenter().postNotificationName(updatePlaylistKey, object: nil)
            })
            CATransaction.commit()
        })
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
