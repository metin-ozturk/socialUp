//
//  PageVC.swift
//  socialUp
//
//  Created by Metin Öztürk on 29.11.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit


protocol CreateEventProtocol : class {
    var event : Event { get set }
    func updateEventInfo()
}

extension CreateEventProtocol {
    func updateEventInfo() {}
}

protocol CreateEventDelegate : class {
    func onEventCreationFinish()
}


class CreateEventPageVC: UIPageViewController {
    
    weak var createEventDelegate : CreateEventDelegate?
    var pastEvent : Event = Event()
    
    private var event = Event()
    
    private var startX : CGFloat?
    private var endX : CGFloat?
    
    private lazy var createEventVCs = [storyboard?.instantiateViewController(withIdentifier: String(describing: WhatVC.self)),
        storyboard?.instantiateViewController(withIdentifier: String(describing: WhoVC.self)),
        storyboard?.instantiateViewController(withIdentifier: String(describing: WhenVC.self)),
        storyboard?.instantiateViewController(withIdentifier: String(describing: WhereVC.self)),
        storyboard?.instantiateViewController(withIdentifier: String(describing: SummaryVC.self))]
    
    private var currentViewControllerIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        (createEventVCs[4] as! SummaryVC).delegate = self
        
        
        // BEGIN: Set Color For CreateEventPageVC Bottom Menu (Dots show which page we are at)
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [CreateEventPageVC.self])
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 0.8)
        pageControl.backgroundColor = .white
        // END

        
        if let firstViewController = createEventVCs.first as? WhatVC {
            firstViewController.event = pastEvent
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        self.scrollView?.panGestureRecognizer.addTarget(self, action: #selector(panned))
    }
    
    
    
//    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
//        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func panned(_ sender: UIPanGestureRecognizer) {

        if (sender.state == UIGestureRecognizer.State.began) {
            startX = sender.translation(in: self.view).x
        } else if (sender.state == UIGestureRecognizer.State.ended) {
            endX = sender.translation(in: self.view).x
            
            if let startX = startX, let endX = endX {
                if (endX - startX > 100 && currentViewControllerIndex == 0) ||
                    (endX - startX < -100 && currentViewControllerIndex == createEventVCs.count - 1)  {
                    cancelEventCreation()
                }
                self.startX = nil
                self.endX = nil
            }
        }
    }
    
    private func cancelEventCreation() {
        let alert = UIAlertController(title: "Cancel Event Creation", message: "Are you sure you want to cancel event creation?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

extension CreateEventPageVC : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = createEventVCs.firstIndex(of: viewController) else {return nil}
        currentViewControllerIndex = viewControllerIndex

        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 && previousIndex < createEventVCs.count else {return nil}
        
        return createEventVCs[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = createEventVCs.firstIndex(of: viewController) else {return nil}
        currentViewControllerIndex = viewControllerIndex
        
        let nextIndex = viewControllerIndex + 1
        
        guard createEventVCs.count > nextIndex else {return nil}
        
        return createEventVCs[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return createEventVCs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
}

extension CreateEventPageVC : UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let currentVC = pageViewController.viewControllers?.first, let pendingVC = pendingViewControllers.first else { return }
                
        retrieveEvent(currentVC: currentVC)
        updateEvent(pendingVC: pendingVC)
    }
    
    private func retrieveEvent(currentVC: UIViewController) {
        let currVC = currentVC as! CreateEventProtocol
        currVC.updateEventInfo()
        event = currVC.event
    }
    
    private func updateEvent(pendingVC: UIViewController) {
        (pendingVC as! CreateEventProtocol).event = event
    }

}

extension UIPageViewController {
    var scrollView : UIScrollView? {
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
}

extension CreateEventPageVC : SummaryVCDelegate {
    func onEventCreationFinish() {
        createEventDelegate?.onEventCreationFinish()
    }
    
}


