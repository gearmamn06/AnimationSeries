//
//  Recursion.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation

import Foundation


public typealias CompleteCallback = (Any) -> Void
public protocol Parameter {}

public protocol Recursable {
    var onNext: (() -> Void)? { get set }
    func start()
}

public class Recursion: Recursable {
    
    let params: Parameter
    var onCompleted: CompleteCallback?
    public var onNext: (() -> Void)?
    
    
    init(params: Parameter, _ complete: CompleteCallback? = nil) {
        self.params = params
        self.onCompleted = complete
    }
    public func start() {}
}


public class RecursionSeries: Recursable {
    
    let first: Recursion
    let last: Recursion
    var loopCount: Int = 0
    var loopCycle: Int
    var loop: ((Int) -> Void)?
    public var onNext: (() -> Void)?
    
    
    init(first: Recursion, last: Recursion, loopCycle: Int = 0) {
        self.first = first
        self.last = last
        self.loopCycle = loopCycle
    }
    
    public func start() {
        first.start()
    }
}


public func + (previous: Recursable, next: Recursable) -> RecursionSeries {
    switch (previous, next) {
    case (is Recursion, is Recursion):
        let previous = previous as! Recursion
        let next = next as! Recursion
        let sender = RecursionSeries(first: previous, last: next)
        next.onNext = {
            // if second unit is end -> call recursion.next to notify this recursion is end
            sender.onNext?()
        }
        previous.onNext = {
            // first unit end -> call next uint
            next.start()
        }
        return sender
        
    case (is Recursion, is RecursionSeries):
        let previous = previous as! Recursion
        let next = next as! RecursionSeries
        let sender = RecursionSeries(first: previous, last: next.last)
        next.onNext = {
            // if second recursion is end -> call recursion.next to notify this recursion is end
            sender.onNext?()
        }
        previous.onNext = {
            // first unit end -> call next recursion
            next.start()
        }
        return sender
        
    case (is RecursionSeries, is Recursion):
        let previous = previous as! RecursionSeries
        let next = next as! Recursion
        let sender = RecursionSeries(first: previous.first, last: next)
        next.onNext = {
            sender.onNext?()
        }
        previous.onNext = {
            // first recursion end -> call next unit
            next.start()
        }
        return sender
        
    default:
        let previous = previous as! RecursionSeries
        let next = next as! RecursionSeries
        let sender = RecursionSeries(first: previous.first, last: next.last)
        next.onNext = {
            sender.onNext?()
        }
        previous.onNext = {
            next.start()
        }
        return sender
    }
}


public func * (chain: RecursionSeries, times: Int) -> RecursionSeries {
    let sender = RecursionSeries(first: chain.first, last: chain.last, loopCycle: times)
    chain.loop = { count in
        let isLoop1CycleEnd = count % times == 0
        if isLoop1CycleEnd {
            // recursion * times end -> exit
            sender.onNext?()
        }else{
            // recursion.end -> recursion.start
            chain.start()
        }
    }
    chain.onNext = {
        // recursion end -> ++ loopCount
        chain.loopCount += 1
        chain.loop?(chain.loopCount)
    }
    return sender
}

