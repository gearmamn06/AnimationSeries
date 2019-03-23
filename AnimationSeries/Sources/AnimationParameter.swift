//
//  AnimationParameter.swift
//  AnimationSeries
//
//  Created by ParkHyunsoo on 23/03/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


public struct AnimationParameter: Parameter {
    internal let duration: TimeInterval
    internal let delay: TimeInterval
    internal let options: UIView.AnimationOptions
    
    public init(_ duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = []) {
        self.duration = duration
        self.delay = delay
        self.options = options
    }
}

