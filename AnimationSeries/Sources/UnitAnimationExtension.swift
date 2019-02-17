//
//  UnitAnimationExtension.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


import UIKit


extension UIView {
    
    /// view.alpha -> 1.0
    func appear(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> Recursion {
        let anim = Appear(self, params: UnitAnimAttr(duration, delay: delay, options: options), complete)
        return anim
    }
    
    /// view.alpha -> 0.0
    func disappear(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> Recursion {
        let anim = Disappear(self, params: UnitAnimAttr(duration, delay: delay, options: options), complete)
        return anim
    }

    /// change view background color
    func discolor(to: UIColor, duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> Recursion {
        let anim = Discolor(self, params: UnitAnimAttr(duration, delay: delay, options: options), color: to, complete: complete)
        return anim
    }
    
    /// translate view position
    func move(position offset: CGPoint, duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> Recursion {
        let anim = Move(self, params: UnitAnimAttr(duration, delay: delay, options: options), destination: offset, complete: complete)
        return anim
    }
    
    /// change view rotating angle
    func rotate(degree: CGFloat, duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> Recursion {
        let anim = Rotate(self, params: UnitAnimAttr(duration, delay: delay, options: options), degree: degree, complete: complete)
        return anim
    }
    
    /// change size of the view
    func sizing(scale to: (CGFloat, CGFloat), duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> Recursion {
        let anim = Sizing(self, params: UnitAnimAttr(duration, delay: delay, options: options), scale: to, complete)
        return anim
    }
}
