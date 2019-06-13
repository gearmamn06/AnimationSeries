//
//  Recursion.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


public typealias CompleteCallback = () -> Void



// MARK: AnimationSeries protocol


public protocol AnimationSeries: class {
    var onNext: (() -> Void)? { get set }
    func start()
    func clear()
    var key: String { get set }
    var animationDidFinish: (() -> Void)? { get set }
}


// MARK: AnimationSeries clear method default implementation

public extension AnimationSeries {
    
    func clear() {
        onNext = nil
        AnimationPool.shared.release(self)
    }
}




// MARK: AnimationSeries traits



// MARK: AnimationAtom for represent single animation
fileprivate protocol AnimationAtom: AnimationSeries {}



// MARK: AnimationCombine


/// concrete implementation of AnimationSeries for serial operation
fileprivate class AnimationCombine: AnimationSeries {
    
    public var key: String = String.ranKey(10) {
        didSet {
            AnimationPool.shared.key(changed: key, from: oldValue)
        }
    }
    
    public var onNext: (() -> Void)?
    public var animationDidFinish: (() -> Void)?
    
    fileprivate var first: AnimationSeries?
    fileprivate weak var currentJob: AnimationSeries?
    
    init(first: AnimationSeries) {
        self.first = first
    }
    
    public func start() {
        first?.start()
    }
    
    public func clear() {
        first = nil
        currentJob?.clear()
        currentJob = nil
        self.onNext = nil
        AnimationPool.shared.release(self)
    }
}




// MARK: ParallelAnimation


/// concrete implementation of AnimationSeries for parallel operation
class ParallelAnimation: AnimationSeries {
    
    
    // public stored properties
    public var key: String = String.ranKey(10) {
        didSet {
            AnimationPool.shared.key(changed: key, from: oldValue)
        }
    }
    public var onNext: (() -> Void)?
    public var animationDidFinish: (() -> Void)?
    
    // internal private stored properties
    private var series: [AnimationSeries] = []
    private var endCount = 0
    
    init(series: AnimationSeries...) {
        self.series = series
        
        series.forEach{
            $0.onNext = self.animationEndBlock
        }
    }
    
    /// this method called when a single animation end -> check all animation end or not
    private func animationEndBlock() {
        if !series.isEmpty {
            endCount += 1
            
            // if all animations were end on this cycle
            if endCount % series.count == 0 {
                self.onNext?()
                self.animationDidFinish?()
            }
        }
    }
    
    public func start() {
        series.forEach{
            $0.start()
        }
    }
    
    public func clear() {
        onNext = nil
        series.forEach {
            $0.clear()
        }
        AnimationPool.shared.release(self)
    }

    func release() {
        self.series.removeAll()
    }
}





// MARK: AnimationSeries operations

/// combine ohe AnimationSeries with another
public func + (previous: AnimationSeries, next: AnimationSeries) -> AnimationSeries {
    let sender = AnimationCombine(first: previous)
    AnimationPool.shared.append(holder: sender, components: previous, next)
    next.onNext = { [weak sender] in
        sender?.onNext?()
        sender?.animationDidFinish?()
    }
    previous.onNext = { [weak sender, weak next] in
        sender?.currentJob = next
        next?.start()
    }
    sender.currentJob = previous
    return sender
}


/// combine two AnimationSeries in parallel
public func | (left: AnimationSeries, right: AnimationSeries) -> AnimationSeries {
    let sender = ParallelAnimation(series: left, right)
    AnimationPool.shared.append(holder: sender, components: left, right)
    return sender
}


public func * (anim: AnimationSeries, times: Int) -> AnimationSeries {
    return anim.doRepeat(times: times)
}

fileprivate extension AnimationSeries {
    
    func doRepeat(times: Int) -> AnimationSeries {
        let sender = AnimationCombine(first: self)
        AnimationPool.shared.append(holder: sender, components: self)
        
        var count = 0
        self.onNext = { [weak self, weak sender] in
            count += 1
            
            if count >= times {
                sender?.onNext?()
                sender?.animationDidFinish?()
            }else{
                self?.start()
            }
        }
        
        sender.currentJob = self
        return sender
    }
}






// MARK: Utils


extension String {
    static var ranKey: (Int) -> String {
        return { len in
            let pool = "abcdefghijklmnopABCDEFGHIJKLMNOP1234567890".map{ $0 }
            return String((0..<len).map{ _ in pool[Int.random(in: 0..<pool.count)] })
        }
    }
}
