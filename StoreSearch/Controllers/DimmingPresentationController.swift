//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Mykhailo Kviatkovskyi on 04.06.2021.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView?.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate { _ in
                self.dimmingView.alpha = 1
            } completion: { _ in }
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: {_ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
