//
//  CombineAnimationTest.swift
//  AnimationSeriesTests
//
//  Created by ParkHyunsoo on 2019/06/12.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import AnimationSeries


class CombineAnimationFlowTest: XCTestCase, SingleAnimationCaseTestable {
    
    var testingTarget: AnimationSeries?
    private var view: UIView!
    
    override func setUp() {
        view = UIView()
    }
    
    override func tearDown() {
        view = nil
        AnimationPool.shared.release(testingTarget)
        testingTarget = nil
    }
}

fileprivate extension SingleAnimationMockup {
    static var quickAnimation: (UIView) -> SingleAnimationMockup {
        return { view in
            let params = ViewAnimation.Parameter(Double.random(in: 0.001...0.01))
            return SingleAnimationMockup(view, params: params)
        }
    }
}

extension CombineAnimationFlowTest {
    
    
    func testCombineFlow() {
        
        let numberOfAnimations = Int.random(in: 10...100)
        var animationFinishCount = 0
        
        let eachAnimationDidFinish: () -> Void = {
            animationFinishCount += 1
        }
        
        var totalDuration: TimeInterval = 0
        
        var combinedAnimation: AnimationSeries
        let firstAnimation = SingleAnimationMockup.quickAnimation(view)
        firstAnimation.animationDidFinish = eachAnimationDidFinish
        
        combinedAnimation = firstAnimation
        totalDuration += firstAnimation.totalDuration
        
        (0..<numberOfAnimations-1).forEach { _ in
            let newAnimation = SingleAnimationMockup.quickAnimation(view)
            newAnimation.animationDidFinish = eachAnimationDidFinish
            
            combinedAnimation = combinedAnimation + newAnimation
            totalDuration += newAnimation.totalDuration
        }
        
        self.testingTarget = combinedAnimation
        
        let promise = expectation(description: "all combined animations are end")
        
        combinedAnimation.animationDidFinish = {
            promise.fulfill()
        }
        
        combinedAnimation.start()
        waitForExpectations(timeout: totalDuration + 5, handler: nil)
        
        
        XCTAssertEqual(numberOfAnimations, animationFinishCount)
    }
}



fileprivate extension SingleAnimationMockup {
    
    var totalDuration: TimeInterval {
        return self.params.duration + self.params.delay
    }
}
