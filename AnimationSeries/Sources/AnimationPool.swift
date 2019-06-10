//
//  AnimationPool.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 31/03/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


public class AnimationPool {
    
    private init() {}
    public static let shared: AnimationPool = AnimationPool()
    
    private var references = [String: Any]()
    private var seriesReferences = [String: AnimationSeries]()
    
    func append(holder: AnimationSeries, components: AnimationSeries...) {
        var ary = references[holder.key] as? [AnimationSeries] ?? [AnimationSeries]()
        components.forEach{ ary.append($0) }
        seriesReferences[holder.key] = holder
        references[holder.key] = ary
    }
    
    func key(changed to: String, from: String) {
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
        if let parallel = seriesReferences[key] as? ParallelAnimation {
            parallel.release()
        }
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
