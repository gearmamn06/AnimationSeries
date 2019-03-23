//
//  AnimationSeries.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


open class ViewAnimation: SingleAnimation {
    
    fileprivate weak var view: UIView?
    
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
        self.view?.layer.removeAllAnimations()
    }
}


/// appear view: view.alpha -> 1.0
class Appear: ViewAnimation {
    
    override func start() {
        guard let params = self.params as? AnimationParameter else {
            onNext?()
            onCompleted?(true)
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.alpha = 1.0
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// disappear view: view.alpha -> 0.0
class Disappear: ViewAnimation {
    
    override func start() {
        guard let params = self.params as? AnimationParameter else {
            onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.alpha = 0.0
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view color: view.backgroundColor -> custom color
class Discolor: ViewAnimation {
    
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
            self.view?.backgroundColor = self.color
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view position
class Move: ViewAnimation {
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
            guard let transform = self.view?.transform.concatenating(CGAffineTransform(translationX: self.destination.x, y: self.destination.y)) else { return}
            self.view?.transform = transform
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view rotation angle
class Rotate: ViewAnimation {
    let radian: CGFloat
    
    init(_ view: UIView, params: AnimationParameter, degree: CGFloat, initFunction: (() -> Void)? = nil,  complete: CompleteCallback?) {
        self.radian = CGFloat(Measurement<UnitAngle>(value: Double(degree), unit: .degrees).converted(to: .radians).value)
        super.init(view, params: params, complete)
    }
    
    
    override func start() {
        guard let params = params as? AnimationParameter else {
            self.onEnd()
            return
        }
        UIView.animate(withDuration: params.duration, delay: params.delay, options: params.options, animations: {
            self.view?.transform = CGAffineTransform(rotationAngle: self.radian)
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}


/// change view scale
class Sizing: ViewAnimation {
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
            self.view?.transform = CGAffineTransform(scaleX: self.scale.0, y: self.scale.1)
        }, completion: { end in
            if end {
                self.onEnd()
            }
        })
    }
}
