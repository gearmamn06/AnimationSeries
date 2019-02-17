//
//  UnitAnimation.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


public struct UnitAnimAttr: Parameter {
    fileprivate let duration: TimeInterval
    fileprivate let delay: TimeInterval
    fileprivate let options: UIView.AnimationOptions
    
    init(_ duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions) {
        self.duration = duration
        self.delay = delay
        self.options = options
    }
}


open class UnitAnimation: Recursion {
    
    fileprivate let view: UIView
    
    init(_ view: UIView, params: UnitAnimAttr, _ complete: CompleteCallback?) {
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


class Appear: UnitAnimation {
    
    override func start() {
        guard let params = self.params as? UnitAnimAttr else {
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

class Disappear: UnitAnimation {
    
    override func start() {
        guard let params = self.params as? UnitAnimAttr else {
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


class Discolor: UnitAnimation {
    
    let color: UIColor
    
    init(_ view: UIView, params: UnitAnimAttr, color: UIColor, complete: CompleteCallback?) {
        self.color = color
        super.init(view, params: params, complete)
    }
    
    override func start() {
        guard let params = params as? UnitAnimAttr else {
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



class Move: UnitAnimation {
    let destination: CGPoint
    
    init(_ view: UIView, params: UnitAnimAttr, destination: CGPoint, complete: CompleteCallback?) {
        self.destination = destination
        super.init(view, params: params, complete)
    }
    
    override func start() {
        guard let params = params as? UnitAnimAttr else {
            self.onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view.transform = CGAffineTransform(translationX: self.destination.x, y: self.destination.y)
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


class Rotate: UnitAnimation {
    let radian: CGFloat
    
    init(_ view: UIView, params: UnitAnimAttr, degree: CGFloat, complete: CompleteCallback?) {
        self.radian = CGFloat(Measurement<UnitAngle>(value: Double(degree), unit: .degrees).converted(to: .radians).value)
        super.init(view, params: params, complete)
    }
    
    
    override func start() {
        guard let params = params as? UnitAnimAttr else {
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


class Sizing: UnitAnimation {
    let scale: (CGFloat, CGFloat)
    init(_ view: UIView, params: UnitAnimAttr, scale: (CGFloat, CGFloat), _ complete: CompleteCallback?) {
        self.scale = scale
        super.init(view, params: params, complete)
    }
    
    override func start() {
        guard let params = self.params as? UnitAnimAttr else {
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
