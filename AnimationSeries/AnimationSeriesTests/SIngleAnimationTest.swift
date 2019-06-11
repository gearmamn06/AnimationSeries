//
//  SIngleAnimationTest.swift
//  AnimationSeriesTests
//
//  Created by ParkHyunsoo on 2019/06/12.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import AnimationSeries



final class SingleAnimationMockup: ViewAnimation {
    
    override func start() {
        let timeout = params.delay + params.duration
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: onEnd)
    }
}


class SingleAnimationTest: XCTestCase {
    
    var view: UIView!
    
    override func setUp() {
        view = UIView()
    }
    
    override func tearDown() {
        view = nil
        AnimationPool.shared.release()
    }
    
    func testAnimationTimming() {
        
        var completeClosureWorking = false
        var animationDidFinishClosureWorking = false
        
        let promise = expectation(description: "execute animation and end right on time")
        
        var intervalToCompleteClosure: TimeInterval = -1
        var intervalToAnimationDidFinishClosure: TimeInterval = -1

        let startTime = Date()
        
        let parameter = ViewAnimation.Parameter(Double.random(in: 0.0..<5.0), delay: Double.random(in: 0.0..<5.0))
        let anim = SingleAnimationMockup(view, params: parameter) {
            intervalToCompleteClosure = Date().timeIntervalSince(startTime)
            completeClosureWorking = true
        }

        anim.animationDidFinish = {
            promise.fulfill()
            intervalToAnimationDidFinishClosure = Date().timeIntervalSince(startTime)
            animationDidFinishClosureWorking = true
        }
        
        anim.start()
        waitForExpectations(timeout: 15, handler: nil)
        
        let precision: TimeInterval = 0.05
        
        let expected = parameter.delay + parameter.duration
        let expectedRange = expected-precision...expected+precision
        
        let resultAnimationDidFinish = expectedRange ~= intervalToAnimationDidFinishClosure
        let resultComplete = expectedRange ~= intervalToCompleteClosure
        
        XCTAssertTrue(completeClosureWorking)
        XCTAssertTrue(animationDidFinishClosureWorking)
        XCTAssertTrue(resultAnimationDidFinish)
        XCTAssertTrue(resultComplete)
    }
}
