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

    let rootController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RootViewController")
    let playlistController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistDrawerController")
    let profileController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController")

    override func viewDidLoad() {
        super.viewDidLoad()
        centralNavigationController = self
        self.delegate = self
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
//        self.popViewControllerAnimated(true)
        self.pushViewController(playlistController, animated: true)
//        self.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PlaylistDrawerController"), animated: true)
    }

    func presentProfile() {
        self.pushViewController(profileController, animated: true)
//        self.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController"), animated: true)
    }

    func leavePlaylist() {
        self.popViewControllerAnimated(true)

//        self.viewControllers.forEach({ print($0 )})
//        self.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RootViewController"), animated: true)
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
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
/*        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        transitionContext.containerView()?.addSubview((toViewController?.view)!)
        toViewController!.view.alpha = 0

        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            toViewController!.view.alpha = 1
            }, completion: {(finished: Bool) in transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })*/
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()!
        let bounds = UIScreen.mainScreen().bounds
        toViewController.view.frame = CGRectOffset(finalFrameForVC, 0, bounds.size.height)
        containerView.addSubview(toViewController.view)
        fromViewController.view.alpha = 0


        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            fromViewController.view.alpha = 0.5
            toViewController.view.frame = finalFrameForVC
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
                fromViewController.view.alpha = 1.0
//                fromViewController.view.removeFromSuperview()
        })

/*        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
            fromViewController.view.alpha = 0.5
            toViewController.view.frame = finalFrameForVC
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
                fromViewController.view.alpha = 1.0
        })*/
    }

    
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
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
/*        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        transitionContext.containerView()?.insertSubview((toViewController?.view)!, belowSubview: (fromViewController?.view)!)
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            fromViewController!.view.alpha = 0
            }, completion: {(finished: Bool) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })*/
    }
}
