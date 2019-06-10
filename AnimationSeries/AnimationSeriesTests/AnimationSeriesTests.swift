//
//  AnimationSeriesTests.swift
//  AnimationSeriesTests
//
//  Created by ParkHyunsoo on 2019/06/11.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
@testable import AnimationSeries

/// for test switch condition
//func => (condition: Bool, action: () -> Void) {
//    if !condition {
//        action()
//    }
//}

class AnimationSeriesTests: XCTestCase {
    
    var view: UIView!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        view = UIView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        view = nil
        AnimationPool.shared.release()
    }
}


extension AnimationSeriesTests {
    
    
    
    func testCombine() {
        
        let promise = expectation(description: "animation count expectation")
        var endCount = 0
        let combine = view.disappear(duration: 1) { _ in
                endCount += 1
            }
            + view.appear(duration: 1) { _ in
                endCount += 1
            }
        
        
        combine.animationDidFinish = {
            promise.fulfill()
        }
        
        combine.start()
        
        waitForExpectations(timeout: 5, handler: nil)
        
        
        XCTAssertTrue(endCount == 2)
    }
    
    func testRepeating() {
        
        let promise = expectation(description: "animation repeating count expectation")
        var count = 0
        
        let combine = (view.disappear(duration: 1) + view.appear(duration: 1))
        combine.animationDidFinish = {
            count += 1
        }
        let repeating = combine * 3

        repeating.animationDidFinish = {
            promise.fulfill()
        }
        repeating.start()
        
        waitForExpectations(timeout: 50, handler: nil)
        
        
        XCTAssertEqual(count, 3+1)
    }
}
