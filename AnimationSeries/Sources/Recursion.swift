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

public protocol Recursable: class {
    var onNext: (() -> Void)? { get set }
    func start()
    func clear()
    var key: String { get set }
}


open class Recursion: Recursable {
    
    public var key: String  = String.ranKey(10) {
        didSet {
            RecursionPool.shared.key(changed: key, from: oldValue)
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
        RecursionPool.shared.flush(self.key)
    }
}


open class RecursionSeries: Recursable {
    
    public var key: String = String.ranKey(10) {
        didSet {
            RecursionPool.shared.key(changed: key, from: oldValue)
        }
    }
    
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
    
    public var onNext: (() -> Void)? = {  }
    
    init(first: Recursable, totalLoopCount: Int = 0) {
        self.first = first
    }
    
    public func start() {
        first?.start()
    }
    
    public func clear() {
        self.isPaused = true
        self.onNext = nil
        RecursionPool.shared.flush(self.key)
    }
}

public class RecursionPool {
    
    private init() {}
    public static let shared: RecursionPool = RecursionPool()
    
    private var references = [String: Any]()
    private var seriesReferences = [String: RecursionSeries]()
    
    fileprivate func append(series: RecursionSeries, recursions: Recursable...) {
        var ary = references[series.key] as? [Recursable] ?? [Recursable]()
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
    
    
    public func flush(_ key: String?) {
        guard let key = key else { return }
        seriesReferences[key] = nil
        guard var ary = self.references[key] as? [Recursable] else { return }
        let keys = ary.map{ $0.key }
        references[key] = nil; ary.removeAll()
        keys.forEach{ flush($0) }
    }
    
    public func flush() {
        seriesReferences.removeAll()
        let keys = references.keys
        keys.forEach(flush(_:))
    }
}


public func + (previous: Recursable, next: Recursable) -> RecursionSeries {
    let sender = RecursionSeries(first: previous)
    RecursionPool.shared.append(series: sender, recursions: previous, next)
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


public func * (series: RecursionSeries, times: Int) -> RecursionSeries {
    let sender = RecursionSeries(first: series, totalLoopCount: times)
    RecursionPool.shared.append(series: sender, recursions: series)
    
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
