//
//  HMStateTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import XCTest
@testable import HMReactiveRedux

public final class HMStateTest: XCTestCase {
	public func test_accessSubstateWithSeparator_shouldWork() {
		/// Setup
		let state1 = HMState.builder().updateState("S1_value", 1).build()
		
		let state2 = HMState.builder()
			.updateState("S2_value", 2)
			.updateSubstate("S1", state1)
			.build()
		
		let state3 = HMState.builder()
			.updateState("S3_value", 3)
			.updateSubstate("S2", state2)
			.build()
		
		let state = HMState.builder()
			.updateState("S4_value", 4)
			.updateSubstate("S3", state3)
			.build()
		
		/// When
		XCTAssertEqual(state.stateValue("S3.S2.S1.S1_value") as! Int, 1)
		XCTAssertEqual(state.stateValue("S3.S2.S2_value") as! Int, 2)
		XCTAssertEqual(state.stateValue("S3.S3_value") as! Int, 3)
		XCTAssertEqual(state.stateValue("S4_value") as! Int, 4)
		XCTAssertNil(state.substate("1.2.3/4/5"))
		XCTAssertNil(state.substate("123"))
		XCTAssertNil(state.stateValue("12345"))
	}
	
	public func test_updateSubState_shouldWork() {
		/// Setup
		let state1_1 = HMState.builder()
			.with(currentState: [
				"value1_11": 1,
				"value1_12": 2,
				"value1_13": 3
				])
			.build()
		
		let state1_2 = HMState.builder()
			.with(currentState: [
				"value1_21": 4,
				"value1_22": 5,
				"value1_23": 6
				])
			.build()
		
		let state2 = HMState.builder()
			.updateSubstate("State1_1", state1_1)
			.updateSubstate("State1_2", state1_2)
			.with(currentState: [
				"value2_11": 7,
				"value2_12": 8,
				"value2_13": 9
				])
			.build()
		
		let state3 = HMState.builder()
			.updateSubstate("State2", state2)
			.with(currentState: [
				"value3_11": 10,
				"value3_12": 11,
				"value3_13": 12
				])
			.build()
		
		/// When
		let updatedState = HMState.builder()
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
		XCTAssertEqual(updated.stateValue("State2.State1_1.value1_11") as! Int, 100)
		XCTAssertEqual(updated.stateValue("State2.State1_1.value1_12") as! Int, 200)
		XCTAssertEqual(updated.stateValue("State2.State1_1.value1_13") as! Int, 300)
		XCTAssertEqual(updated.stateValue("State2.State1_2.value1_21") as! Int, 4)
		XCTAssertEqual(updated.stateValue("State2.State1_2.value1_22") as! Int, 5)
		XCTAssertEqual(updated.stateValue("State2.State1_2.value1_23") as! Int, 6)
		XCTAssertEqual(updated.stateValue("State2.value2_11") as! Int, 7)
		XCTAssertEqual(updated.stateValue("State2.value2_12") as! Int, 1000)
		XCTAssertEqual(updated.stateValue("State2.value2_13") as! Int, 9)
		XCTAssertEqual(updated.stateValue("value3_11") as! Int, 10)
		XCTAssertEqual(updated.stateValue("value3_12") as! Int, 11)
		XCTAssertEqual(updated.stateValue("value3_13") as! Int, 12)
		XCTAssertEqual(updated.stateValue("Test1.Test2.Test3.Test4.test4_value") as! Int, 10000)
		XCTAssertEqual(updated.stateValue("123.456.789") as! Int, 123456789)
	}
}
