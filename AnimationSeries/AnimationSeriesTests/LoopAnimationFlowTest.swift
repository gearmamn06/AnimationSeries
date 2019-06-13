//
//  LoopAnimationCountTest.swift
//  AnimationSeriesTests
//
//  Created by ParkHyunsoo on 2019/06/14.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import AnimationSeries

final class ExternalCuontSingleAnimationMockup: SingleAnimationMockup {
    
    override func start() {
        LoopAnimationFlowTest.startCount += 1
        super.start()
    }
}


class LoopAnimationFlowTest: XCTestCase, SingleAnimationCaseTestable {
    
    var testingTarget: AnimationSeries?
    private var view: UIView!
    fileprivate static var startCount: Int = 0
    
    override func setUp() {
        view = UIView()
    }
    
    override func tearDown() {
        view = nil
        AnimationPool.shared.release(testingTarget)
        testingTarget = nil
        LoopAnimationFlowTest.startCount = 0
    }
}



extension LoopAnimationFlowTest {
    
    func testLoopCount() {
        
        let numberOfAnimation = Int.random(in: 10...100)
        
        let singleAnimation = ExternalCuontSingleAnimationMockup.quickAnimation(view)
        let loopAnimation = singleAnimation * numberOfAnimation
        
        let expectDuration: TimeInterval = Double(singleAnimation.params.delay
            + singleAnimation.params.duration)
        
        let promise = expectation(description: "LoopAnimation should end")
        
        loopAnimation.animationDidFinish = {
            promise.fulfill()
        }
        
        loopAnimation.start()
        waitForExpectations(timeout: expectDuration + 5, handler: nil)
        
        print("count: \(LoopAnimationFlowTest.startCount)")
        let countTestResult = LoopAnimationFlowTest.startCount == numberOfAnimation
        
        XCTAssertTrue(countTestResult)
    }
}


fileprivate extension ExternalCuontSingleAnimationMockup {
    
    static var quickAnimation: (UIView) -> ExternalCuontSingleAnimationMockup {
        return { view in
            let params = ViewAnimation.Parameter(Double.random(in: 0.001...0.01))
            return ExternalCuontSingleAnimationMockup(view, params: params)
        }
    }
}
