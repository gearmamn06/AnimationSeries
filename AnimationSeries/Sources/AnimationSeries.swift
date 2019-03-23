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


extension String {
    static var ranKey: (Int) -> String {
        return { len in
            let pool = "abcdefghijklmnopABCDEFGHIJKLMNOP1234567890".map{ $0 }
            return String((0..<len).map{ _ in pool[Int.random(in: 0..<pool.count)] })
        }
    }
}

public protocol AnimationSeries: class {
    var onNext: (() -> Void)? { get set }
    func start()
    func clear()
    var key: String { get set }
}


open class SingleAnimation: AnimationSeries {
    
    public var key: String  = String.ranKey(10) {
        didSet {
            AnimationPool.shared.key(changed: key, from: oldValue)
        }
    }
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
        AnimationPool.shared.release(self)
    }
}


open class ChainAnimation: AnimationSeries {
    
    public var key: String = String.ranKey(10) {
        didSet {
            AnimationPool.shared.key(changed: key, from: oldValue)
        }
    }
    
    fileprivate var first: AnimationSeries?
    
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
    fileprivate weak var currentJob: AnimationSeries?
    
    public var onNext: (() -> Void)? = {  }
    
    init(first: AnimationSeries, totalLoopCount: Int = 0) {
        self.first = first
    }
    
    public func start() {
        first?.start()
    }
    
    public func clear() {
        self.isPaused = true
        self.onNext = nil
        AnimationPool.shared.release(self)
    }
}

public class AnimationPool {
    
    private init() {}
    public static let shared: AnimationPool = AnimationPool()
    
    private var references = [String: Any]()
    private var seriesReferences = [String: ChainAnimation]()
    
    fileprivate func append(series: ChainAnimation, recursions: AnimationSeries...) {
        var ary = references[series.key] as? [AnimationSeries] ?? [AnimationSeries]()
        recursions.forEach{ ary.append($0) }
        seriesReferences[series.key] = series
        references[series.key] = ary
    }
    
    fileprivate func key(changed to: String, from: String) {
        seriesReferences[to] = seriesReferences[from]
        seriesReferences[to] = nil
        guard let ary = references[from] else { return }
        references[to] = ary
    }
    
    
    public func release(_ series: AnimationSeries?) {
        release(series?.key)
    }
    
    private func release(_ key: String?) {
        guard let key = key else { return }
        seriesReferences[key] = nil
        guard var ary = self.references[key] as? [AnimationSeries] else { return }
        let keys = ary.map{ $0.key }
        references[key] = nil; ary.removeAll()
        keys.forEach{ release($0) }
    }
    
    public func release() {
        seriesReferences.removeAll()
        let keys = references.keys
        keys.forEach(release(_:))
    }
}


public func + (previous: AnimationSeries, next: AnimationSeries) -> AnimationSeries {
    let sender = ChainAnimation(first: previous)
    AnimationPool.shared.append(series: sender, recursions: previous, next)
    next.onNext = { [weak sender] in
        sender?.onNext?()
    }
    previous.onNext = { [weak sender, weak next] in
        sender?.currentJob = next
        next?.start()
    }
    sender.currentJob = previous
    return sender
}

public func * (anim: AnimationSeries, times: Int) -> AnimationSeries {
    if let single = anim as? SingleAnimation {
        return single * times
    }else if let chain = anim as? ChainAnimation {
        return chain * times
    }else{
        return anim
    }
}


private func * (single: SingleAnimation, times: Int) -> AnimationSeries {
    let sender = ChainAnimation(first: single, totalLoopCount: times)
    AnimationPool.shared.append(series: sender, recursions: single)
    var count = 0
    single.onNext = { [weak single, weak sender] in
        count += 1

        if count > times {
            sender?.onNext?()
        }else{
            single?.start()
        }
    }
    sender.currentJob = single
    return sender
}

private func * (series: ChainAnimation, times: Int) -> AnimationSeries {
    let sender = ChainAnimation(first: series, totalLoopCount: times)
    AnimationPool.shared.append(series: sender, recursions: series)
    
    series.onNext = { [weak series, weak sender] in
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
