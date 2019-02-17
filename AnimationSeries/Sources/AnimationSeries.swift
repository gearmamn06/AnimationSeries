//
//  AnimationSeries.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


public struct AnimationParameter: Parameter {
    internal let duration: TimeInterval
    internal let delay: TimeInterval
    internal let options: UIView.AnimationOptions
    
    init(_ duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions) {
        self.duration = duration
        self.delay = delay
        self.options = options
    }
}


open class AnimationSeries: Recursion {
    
    fileprivate let view: UIView
    
    init(_ view: UIView, params: AnimationParameter, _ complete: CompleteCallback?) {
        self.view = view
        super.init(params: params, complete)
    }
    
    func onEnd() {
        self.onNext?()
        self.onCompleted?(true)
    }
    
    override public func clear() {
        super.clear()
        self.view.layer.removeAllAnimations()
    }
}


/// appear view: view.alpha -> 1.0
class Appear: AnimationSeries {
    
    override func start() {
        guard let params = self.params as? AnimationParameter else {
            onNext?()
            onCompleted?(true)
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view.alpha = 1.0
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// disappear view: view.alpha -> 0.0
class Disappear: AnimationSeries {
    
    override func start() {
        guard let params = self.params as? AnimationParameter else {
            onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view.alpha = 0.0
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view color: view.backgroundColor -> custom color
class Discolor: AnimationSeries {
    
    let color: UIColor
    
    init(_ view: UIView, params: AnimationParameter, color: UIColor, complete: CompleteCallback?) {
        self.color = color
        super.init(view, params: params, complete)
    }
    
    override func start() {
        guard let params = params as? AnimationParameter else {
            onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view.backgroundColor = self.color
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view position
class Move: AnimationSeries {
    let destination: CGPoint
    
    init(_ view: UIView, params: AnimationParameter, destination: CGPoint, complete: CompleteCallback?) {
        self.destination = destination
        super.init(view, params: params, complete)
    }
    
    override func start() {
        guard let params = params as? AnimationParameter else {
            self.onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            let transform = self.view.transform.concatenating(CGAffineTransform(translationX: self.destination.x, y: self.destination.y))
            self.view.transform = transform
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view rotation angle
class Rotate: AnimationSeries {
    let radian: CGFloat
    
    init(_ view: UIView, params: AnimationParameter, degree: CGFloat, complete: CompleteCallback?) {
        self.radian = CGFloat(Measurement<UnitAngle>(value: Double(degree), unit: .degrees).converted(to: .radians).value)
        super.init(view, params: params, complete)
    }
    
    
    override func start() {
        guard let params = params as? AnimationParameter else {
            self.onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view.transform = CGAffineTransform(rotationAngle: self.radian)
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view scale
class Sizing: AnimationSeries {
    let scale: (CGFloat, CGFloat)
    init(_ view: UIView, params: AnimationParameter, scale: (CGFloat, CGFloat), _ complete: CompleteCallback?) {
        self.scale = scale
        super.init(view, params: params, complete)
    }
    
    override func start() {
        guard let params = self.params as? AnimationParameter else {
            onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view.transform = CGAffineTransform(scaleX: self.scale.0, y: self.scale.1)
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}
