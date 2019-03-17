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
    
    fileprivate var first: Recursable?
    
    fileprivate var loopCount: Int = 0
    
    fileprivate var isPaused = false {
        didSet {
            if isPaused {
                first = nil
                currentJob?.clear()
                currentJob = nil
            }
        }
    }
    fileprivate weak var currentJob: Recursable?
    
    public var onNext: (() -> Void)?
    
    
    init(first: Recursable, totalLoopCount: Int = 0) {
        self.first = first
//        self.totalLoopCount = totalLoopCount
    }
    
    public func start() {
        first?.start()
    }
    
    public func clear() {
        self.isPaused = true
        self.onNext = nil
//        self.loop = nil
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


public func * (series: RecursionSeries, times: Int) -> RecursionSeries {
    let sender = RecursionSeries(first: series, totalLoopCount: times)
    
    series.onNext = { [weak sender, weak series] in
        // series end -> loopCount++ -> loop
        series?.loopCount += 1
        
        if series?.loopCount ?? times >= times {
            series?.loopCount = 0
            sender?.onNext?()
            
        }else{
            series?.start()
        }
    }
    sender.currentJob = series
    return sender
}
