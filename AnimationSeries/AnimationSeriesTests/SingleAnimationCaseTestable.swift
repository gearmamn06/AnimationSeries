//
//  SingleAnimationCaseTestable.swift
//  AnimationSeriesTests
//
//  Created by ParkHyunsoo on 2019/06/12.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import AnimationSeries

protocol SingleAnimationCaseTestable {
    
    var testingTarget: AnimationSeries? { get set }
}
