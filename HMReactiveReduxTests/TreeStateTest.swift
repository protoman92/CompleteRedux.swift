//
//  HMStateTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import XCTest
@testable import HMReactiveRedux

public final class TreeStateTest: XCTestCase {
	public func test_accessSubstateWithSeparator_shouldWork() {
		/// Setup
		let state1 = TreeState.builder().updateValue("S1_value", 1).build()
		
		let state2 = TreeState.builder()
			.updateValue("S2_value", 2)
			.updateSubstate("S1", state1)
			.build()
		
		let state3 = TreeState.builder()
			.updateValue("S3_value", 3)
			.updateSubstate("S2", state2)
			.build()
		
		let state = TreeState.builder()
			.updateValue("S4_value", 4)
			.updateSubstate("S3", state3)
			.build()
		
		/// When
		XCTAssertEqual(state.stateValue("S3.S2.S1.S1_value").value!, 1)
		XCTAssertEqual(state.stateValue("S3.S2.S2_value").value!, 2)
		XCTAssertEqual(state.stateValue("S3.S3_value").value!, 3)
		XCTAssertEqual(state.stateValue("S4_value").value!, 4)
		XCTAssertNil(state.substate("1.2.3/4/5").value)
		XCTAssertNil(state.substate("123").value)
		XCTAssertNil(state.stateValue("12345").value)
	}
	
	public func test_updateSubState_shouldWork() {
		/// Setup
		let state1_1 = TreeState.builder()
			.with(currentState: [
				"value1_11": 1,
				"value1_12": 2,
				"value1_13": 3
				])
			.build()
		
		let state1_2 = TreeState.builder()
			.with(currentState: [
				"value1_21": 4,
				"value1_22": 5,
				"value1_23": 6
				])
			.build()
		
		let state2 = TreeState.builder()
			.updateSubstate("State1_1", state1_1)
			.updateSubstate("State1_2", state1_2)
			.with(currentState: [
				"value2_11": 7,
				"value2_12": 8,
				"value2_13": 9
				])
			.build()
		
		let state3 = TreeState.builder()
			.updateSubstate("State2", state2)
			.with(currentState: [
				"value3_11": 10,
				"value3_12": 11,
				"value3_13": 12
				])
			.build()
		
		/// When
		let updatedState = TreeState.builder()
			.with(currentState: [
				"value1_11": 100,
				"value1_12": 200,
				"value1_13": 300
				])
			.build()
		
		let updated = state3
			.updateSubstate("State2.State1_1", updatedState)
			.updateValue("State2.value2_12", 1000)
			.updateValue("Test1.Test2.Test3.Test4.test4_value", 10000)
			.updateValue("123.456.789", 123456789)
		
		/// Then
		XCTAssertEqual(updated.stateValue("State2.State1_1.value1_11").value!, 100)
		XCTAssertEqual(updated.stateValue("State2.State1_1.value1_12").value!, 200)
		XCTAssertEqual(updated.stateValue("State2.State1_1.value1_13").value!, 300)
		XCTAssertEqual(updated.stateValue("State2.State1_2.value1_21").value!, 4)
		XCTAssertEqual(updated.stateValue("State2.State1_2.value1_22").value!, 5)
		XCTAssertEqual(updated.stateValue("State2.State1_2.value1_23").value!, 6)
		XCTAssertEqual(updated.stateValue("State2.value2_11").value!, 7)
		XCTAssertEqual(updated.stateValue("State2.value2_12").value!, 1000)
		XCTAssertEqual(updated.stateValue("State2.value2_13").value!, 9)
		XCTAssertEqual(updated.stateValue("value3_11").value!, 10)
		XCTAssertEqual(updated.stateValue("value3_12").value!, 11)
		XCTAssertEqual(updated.stateValue("value3_13").value!, 12)
		XCTAssertEqual(updated.stateValue("Test1.Test2.Test3.Test4.test4_value").value!, 10000)
		XCTAssertEqual(updated.stateValue("123.456.789").value!, 123456789)
	}
}
