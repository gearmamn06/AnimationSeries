//
//  AnimationSeries.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

// MARK: ViewAnimation


/// ViewAnimation foundation: store parameter & target view & common cancel logic
open class ViewAnimation: AnimationSeries {
    
    /// parameter of the view animation
    public struct Parameter {
        internal let duration: TimeInterval
        internal let delay: TimeInterval
        internal let options: UIView.AnimationOptions
        
        public init(_ duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = []) {
            self.duration = duration
            self.delay = delay
            self.options = options
        }
    }
    
    
    // public stored properties
    public var onNext: (() -> Void)?
    public var animationDidFinish: (() -> Void)?
    public var key: String = String.ranKey(10) {
        didSet {
            AnimationPool.shared.key(changed: key, from: oldValue)
        }
    }

    // internal fileprivate properties
    fileprivate weak var view: UIView?
    let params:  ViewAnimation.Parameter
    fileprivate let onCompleted: CompleteCallback?
    
    init(_ view: UIView, params: ViewAnimation.Parameter, _ complete: CompleteCallback? = nil) {
        self.view = view
        self.params = params
        self.onCompleted = complete
    }
    
    
    func onEnd() {
        self.onNext?()
        self.onCompleted?()
        self.animationDidFinish?()
    }
    
    
    // AnimationSeries methods and implmentation
    public func start() {}
    public func clear() {
        onNext = nil
        self.view?.layer.removeAllAnimations()
        AnimationPool.shared.release(self)
    }
}


/// appear view: view.alpha -> 1.0
class Appear: ViewAnimation {
    
    override func start() {
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.alpha = 1.0
        }, completion: { end in
            end => self.onEnd
        })
    }
}


/// disappear view: view.alpha -> 0.0
class Disappear: ViewAnimation {
    
    override func start() {
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.alpha = 0.0
        }, completion: { end in
            end => self.onEnd
        })
    }
}


/// change view color: view.backgroundColor -> custom color
class Discolor: ViewAnimation {
    
    let color: UIColor
    
    init(_ view: UIView, params:  ViewAnimation.Parameter, color: UIColor, complete: CompleteCallback?) {
        self.color = color
        super.init(view, params: params, complete)
    }
    
    override func start() {
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.backgroundColor = self.color
        }, completion: { end in
            end => self.onEnd
        })
    }
}


/// change view position
class Move: ViewAnimation {
    let destination: CGPoint
    
    init(_ view: UIView, params:  ViewAnimation.Parameter, destination: CGPoint, complete: CompleteCallback?) {
        self.destination = destination
        super.init(view, params: params, complete)
    }
    
    override func start() {
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            guard let transform = self.view?.transform.concatenating(CGAffineTransform(translationX: self.destination.x, y: self.destination.y)) else { return}
            self.view?.transform = transform
        }, completion: { end in
            end => self.onEnd
        })
    }
}


/// change view rotation angle
class Rotate: ViewAnimation {
    let radian: CGFloat
    
    init(_ view: UIView, params:  ViewAnimation.Parameter, degree: CGFloat, initFunction: (() -> Void)? = nil,  complete: CompleteCallback?) {
        self.radian = CGFloat(Measurement<UnitAngle>(value: Double(degree), unit: .degrees).converted(to: .radians).value)
        super.init(view, params: params, complete)
    }
    
    
    override func start() {
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.transform = CGAffineTransform(rotationAngle: self.radian)
        }, completion: { end in
            end => self.onEnd
        })
    }
}


/// change view scale
class Sizing: ViewAnimation {
    let scale: (CGFloat, CGFloat)
    init(_ view: UIView, params:  ViewAnimation.Parameter, scale: (CGFloat, CGFloat), _ complete: CompleteCallback?) {
        self.scale = scale
        super.init(view, params: params, complete)
    }
    
    override func start() {
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.transform = CGAffineTransform(scaleX: self.scale.0, y: self.scale.1)
        }, completion: { end in
            end => self.onEnd
        })
    }
}



infix operator =>

fileprivate func => (condition: Bool, action: () -> Void) {
    if condition {
        action()
    }
}
