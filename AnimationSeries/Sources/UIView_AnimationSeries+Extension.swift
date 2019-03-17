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
    
    
    
    /// view.alpha -> 1.0 with flat parameters
    public func appear(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> AnimationSeries {
        let anim = Appear(self, params: AnimationParameter(duration, delay: delay, options: options), complete)
        return anim
    }
    
    
    /// view.alpha -> 1.0 with AnimationParameter
    public func appear(_ params: AnimationParameter, _ complete: CompleteCallback? = nil) -> AnimationSeries {
        return self.appear(duration: params.duration, delay: params.delay, options: params.options, complete)
    }
    
    
    /// view.alpha -> 0.0 with flat parameters
    public func disappear(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> AnimationSeries {
        let anim = Disappear(self, params: AnimationParameter(duration, delay: delay, options: options), complete)
        return anim
    }
    
    
    /// view.alpha -> 0.0 with AnimationParameter
    public func disappear(_ params: AnimationParameter, _ complete: CompleteCallback? = nil) -> AnimationSeries {
        return self.disappear(duration: params.duration, delay: params.delay, options: params.options, complete)
    }

    
    
    /// change view background color with flat parameters
    public func discolor(to: UIColor, duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> AnimationSeries {
        let anim = Discolor(self, params: AnimationParameter(duration, delay: delay, options: options), color: to, complete: complete)
        return anim
    }
    
    /// change view background color with AnimationParameter
    public func discolor(to: UIColor, params: AnimationParameter, complete: CompleteCallback? = nil) -> AnimationSeries {
        return discolor(to: to, duration: params.duration, delay: params.delay, options: params.options, complete)
    }
    
    
    
    /// translate view position with flat parameters
    public func move(position offset: CGPoint, duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> AnimationSeries {
        let anim = Move(self, params: AnimationParameter(duration, delay: delay, options: options), destination: offset, complete: complete)
        return anim
    }
    
    
    /// translate view position with with AnimationParameter
    public func move(position offset: CGPoint, params: AnimationParameter, complete: CompleteCallback? = nil) -> AnimationSeries {
        return self.move(position: offset, duration: params.duration, delay: params.delay, options: params.options, complete)
    }
    
    
    
    /// change view rotation angle with flat parameters
    public func rotate(degree: CGFloat, duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> AnimationSeries {
        let anim = Rotate(self, params: AnimationParameter(duration, delay: delay, options: options), degree: degree, complete: complete)
        return anim
    }
    
    
    /// change view rotation angle with AnimationParameter
    public func rotate(degree: CGFloat, params: AnimationParameter, complete: CompleteCallback? = nil) -> AnimationSeries {
        return self.rotate(degree: degree, duration: params.duration, delay: params.delay, options: params.options, complete)
    }
    
    
    
    /// change size of the view with flat parameters
    public func sizing(scale to: (CGFloat, CGFloat), duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], _ complete: CompleteCallback? = nil) -> AnimationSeries {
        let anim = Sizing(self, params: AnimationParameter(duration, delay: delay, options: options), scale: to, complete)
        return anim
    }
    
    
    /// change size of the view with AnimationParameter
    public func sizing(scale to: (CGFloat, CGFloat), params: AnimationParameter, complete: CompleteCallback? = nil) -> AnimationSeries {
        return self.sizing(scale: to, duration: params.duration, delay: params.delay, options: params.options, complete)
    }
}
