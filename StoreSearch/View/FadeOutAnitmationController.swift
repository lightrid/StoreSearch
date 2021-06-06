//
//  FadeOutAnitmationController.swift
//  StoreSearch
//
//  Created by Mykhailo Kviatkovskyi on 05.06.2021.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        
        let time = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: time) {
            fromView.alpha = 0
        } completion: { (finished) in
            transitionContext.completeTransition(finished)
        }

    }
    
    
}
