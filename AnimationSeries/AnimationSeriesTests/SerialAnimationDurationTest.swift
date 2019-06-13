//
//  SerialAnimationDurationTest.swift
//  AnimationSeriesTests
//
//  Created by ParkHyunsoo on 2019/06/14.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import AnimationSeries



final class DurationRecordableAnimation: ViewAnimation {
    
    private var animationStartTime: Date?
    
    override func onEnd() {
        if let startTime = animationStartTime {
            let interval = Date().timeIntervalSince(startTime)
            SerialAnimationDurationTest.totalAnimationDuration += interval
        }
        super.onEnd()
    }
    
    override func start() {
        animationStartTime = Date()
        let timeOut = params.duration + params.delay
        DispatchQueue.main.asyncAfter(deadline: .now() + timeOut, execute: onEnd)
    }
}


class SerialAnimationDurationTest: XCTestCase, SingleAnimationCaseTestable {
    
    var testingTarget: AnimationSeries?
    private var view: UIView!
    
    static var totalAnimationDuration: TimeInterval = 0
    
    override func setUp() {
        view = UIView()
    }
    
    override func tearDown() {
        view = nil
        AnimationPool.shared.release(testingTarget)
        testingTarget = nil
        SerialAnimationDurationTest.totalAnimationDuration = 0
    }
}


extension SerialAnimationDurationTest {
    
    func testAnimationEndTime() {
        var totalDuration: TimeInterval = 0
        
        let size = Int.random(in: 3..<10)
        
        var combination: AnimationSeries!
        
        (0..<size).forEach { _ in
            
            let duration = Double.random(in: 0.5..<1)
            let delay = Double.random(in: 0.5..<1)
            let params = ViewAnimation.Parameter(duration, delay: delay)
            
            totalDuration += duration + delay
            
            if combination == nil {
                combination = DurationRecordableAnimation(view, params: params)
            }else{
                combination = combination +  DurationRecordableAnimation(view, params: params)
            }
        }
        
        let promise = expectation(description: "combinedAnimation all end")
        
        combination.animationDidFinish = {
            promise.fulfill()
        }
        combination.start()
        
        waitForExpectations(timeout: totalDuration + 5, handler: nil)
        
        
        let gap = abs(SerialAnimationDurationTest.totalAnimationDuration - totalDuration)
        let precision: TimeInterval = 0.1 * Double(size)
        
        let result = gap <= precision
        
        XCTAssertTrue(result)
    }
}
