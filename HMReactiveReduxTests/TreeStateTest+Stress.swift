//
//  TreeStateTest+Stress.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import XCTest
import SwiftUtilities
@testable import HMReactiveRedux

public final class TreeStateStressTest: XCTestCase {
	fileprivate var alphabets: [String]!
	fileprivate var keyCount: Int!
	fileprivate var keys: [String]!
	fileprivate var keyValues: [String : Int]!

	override public func setUp() {
		super.setUp()
		let letters = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
		alphabets = letters.components(separatedBy: " ")
		keyCount = 10000
		keys = []
		keyValues = [:]

		for _ in (0..<keyCount!) {
			let length = (1..<alphabets!.count).map({$0}).randomElement()!
			let key = (0..<length).map({_ in alphabets.randomElement()!}).joined()
			let value = Int.random(0, 1000000)
			keys.append(key)
			keyValues.updateValue(value, forKey: key)
		}
	}

	public func test_updateStateWithKeyValues_shouldWork() {
		/// Setup
		var state = TreeState<Int>.empty()

		/// When
		state = state.updateValues(keyValues!)

		/// Then
		for key in keys! {
			let value = keyValues[key]!
			let stateValue = state.stateValue(key).value!
			XCTAssertEqual(stateValue, value)
		}

		state = state.removeValues(keys!)
		XCTAssertTrue(state.isEmpty())
		print(state)
	}
}
