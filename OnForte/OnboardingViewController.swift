//
//  OnboardingViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 3/29/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import Foundation
import UIKit

class OnboardingCreateViewController: UIViewController {
    @IBOutlet var gifView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        renderGif()
    }
    
    func renderGif() {
/*        if let exampleGif = UIImage.gifWithName("frontpage_gif") {
            let exampleGifView = UIImageView(image: exampleGif)
            gifView.addSubview(exampleGifView)
            let constraints = Style.constrainToBoundsOfFrame(exampleGifView, parentView: gifView)
            exampleGifView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(constraints)
        } */
    }
    
}

class OnboardingContributionViewController: UIViewController {
    
}





class OnboardingFinalViewController : UIViewController {
    
    @IBOutlet var doneButtonView: UIView!
    @IBOutlet var gifView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderDoneButton()
        renderGif()
    }
    
    func renderGif() {
/*        if let exampleGif = UIImage.gifWithName("frontpage_gif") {
            let exampleGifView = UIImageView(image: exampleGif)
            gifView.addSubview(exampleGifView)
            let constraints = Style.constrainToBoundsOfFrame(exampleGifView, parentView: gifView)
            exampleGifView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activateConstraints(constraints)
        }*/
    }
    
    func renderDoneButton() {
        let button = UIButton(type: .System)
        button.setTitle("Complete Onboarding", forState: .Normal  )
        button.addTarget(self, action: #selector(OnboardingFinalViewController.doneOnboarding(_:)), forControlEvents: .TouchUpInside)
        doneButtonView.addSubview(button)
        let constraints = Style.constrainToBoundsOfFrame(button, parentView: doneButtonView)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func doneOnboarding(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: onboardingKey)
//        Settings.groupDefaults().setBool(true, forKey: onboardingKey)
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        ad.launchStoryboard(Storyboard.Main)
        
    }
}