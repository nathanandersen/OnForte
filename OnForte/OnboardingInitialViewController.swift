//
//  OnboardingInitialViewController.swift
//  Forte
//
//  Created by Nathan Andersen on 3/30/16.
//  Copyright © 2016 Nathan Andersen. All rights reserved.
//

import UIKit

class OnboardingInitialViewController: UIViewController, UIPageViewControllerDataSource,UIPageViewControllerDelegate {

    @IBOutlet var pageControl: UIPageControl!
    
    var pageViewController: UIPageViewController?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("Creation"),
                self.newViewController("Contribution"),
                self.newViewController("Final")]
    }()
    
    private func newViewController(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Onboarding", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(identifier)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.numberOfPages = self.orderedViewControllers.count
        
       pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            pageViewController!.setViewControllers([firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
        }
        self.pageViewController!.dataSource = self
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController?.didMoveToParentViewController(self)
        self.view.gestureRecognizers = self.pageViewController?.gestureRecognizers
        
        self.view.bringSubviewToFront(pageControl)
        
    }
    
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        
        let currentViewController = self.pageViewController?.viewControllers?.last
        let indexOfCurrentPage = self.orderedViewControllers.indexOf(currentViewController!)
        self.pageControl.currentPage = indexOfCurrentPage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
