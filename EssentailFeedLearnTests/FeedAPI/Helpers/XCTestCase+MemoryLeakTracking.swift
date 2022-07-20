//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentailFeedLearnTests
//
//  Created by Pavan More on 19/07/22.
//
import XCTest


extension XCTestCase {
     func trackMemoryLeak(_ instance: AnyObject,file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
           XCTAssertNil(instance, "Instance should have been deallcocated potential memory leak.", file: file, line: line)
        }
    }
}
