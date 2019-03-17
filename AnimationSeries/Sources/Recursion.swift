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


public protocol Recursable: class {
    var onNext: (() -> Void)? { get set }
    func start()
    func clear()
}

open class Recursion: Recursable {
    
    let params: Parameter
    var onCompleted: CompleteCallback?
    public var onNext: (() -> Void)?
    
    init(params: Parameter, _ complete: CompleteCallback? = nil) {
        self.params = params
        self.onCompleted = complete
    }
    
    public func start() {}
    
    public func clear() {
        self.onNext = nil
    }
}


open class RecursionSeries: Recursable {
    
    fileprivate let first: Recursable
    
    fileprivate var loopCount: Int = 0
    fileprivate var totalLoopCount: Int
    fileprivate var loop: ((Int) -> Void)?
    
    fileprivate var isPaused = false {
        didSet {
            if isPaused {
                currentJob?.clear()
            }
        }
    }
    fileprivate weak var currentJob: Recursable?
    
    public var onNext: (() -> Void)?
    
    
    init(first: Recursable, totalLoopCount: Int = 0) {
        self.first = first
        self.totalLoopCount = totalLoopCount
    }
    
    public func start() {
        first.start()
    }
    
    public func clear() {
        self.isPaused = true
        self.onNext = nil
        self.loop = nil
    }
}


public func + (previous: Recursable, next: Recursable) -> RecursionSeries {
    let sender = RecursionSeries(first: previous)
    next.onNext = { [weak sender] in
        sender?.onNext?()
    }
    previous.onNext = { [weak sender] in
        sender?.currentJob = next
        next.start()
    }
    sender.currentJob = previous
    return sender
}

public func * (recursion: Recursion, times: Int) -> RecursionSeries {
    let sender = RecursionSeries(first: recursion, totalLoopCount: times)
    
    var count = 0
    recursion.onNext = { [weak sender] in
        count += 1
        if count >= times {
            sender?.onNext?()
        }else{
            recursion.start()
        }
    }
    return sender
}


public func * (series: RecursionSeries, times: Int) -> RecursionSeries {
    let sender = RecursionSeries(first: series, totalLoopCount: times)
    series.loop = { [weak sender] count in
        
        let isLoop1CycleEnd = count % times == 0
        if isLoop1CycleEnd {
            // (series end) * totalLoopCount -> exit
            sender?.onNext?()
        }else{
            // series end -> (loop) -> start
            series.start()
        }
    }
    series.onNext = {
        // series end -> loopCount++ -> loop
        series.loopCount += 1
        series.loop?(series.loopCount)
    }
    sender.currentJob = series
    return sender
}

