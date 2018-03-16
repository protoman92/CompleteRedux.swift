//
//  RxReduxStoreTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxTest
import RxSwift
import SwiftFP
import SwiftUtilities
import SwiftUtilitiesTests
import XCTest
@testable import HMReactiveRedux

public class SubState {
	public static let layer1 = "layer1"
	public static let layer2 = "layer2"
	public static let layer3 = "layer3"
}

public class State {
	public static let calculation = "calculation"
}

public enum Action: ReduxActionType, EnumerableType {
	case add
	case addTwo
	case addThree
	case minus
	
	public static func allValues() -> [Action] {
		return [add, addTwo, addThree, minus]
	}
	
	public func updateFn() -> TreeState<Int>.UpdateFn {
		switch self {
		case .add: return {$0.map({$0 + 1})}
		case .addTwo: return {$0.map({$0 + 2})}
		case .addThree: return {$0.map({$0 + 3})}
		case .minus: return {$0.map({$0 - 1})}
		}
	}
}

public final class RxReduxStoreTest: XCTestCase {
	fileprivate var disposeBag: DisposeBag!
	fileprivate var scheduler: TestScheduler!
	fileprivate var initialState: TreeState<Int>!
	fileprivate var store: RxReduxStore<Int>!
	
	fileprivate var updateId: String {
		return "layer1.layer2.layer3.calculation"
	}
	
	override public func setUp() {
		super.setUp()
		scheduler = TestScheduler(initialClock: 0)
		disposeBag = DisposeBag()
		
		let layer3 = TreeState<Int>.builder()
			.updateValue(State.calculation, 0)
			.build()
		
		let layer2 = TreeState<Int>.builder()
			.updateSubstate(SubState.layer3, layer3)
			.build()
		
		let layer1 = TreeState<Int>.builder()
			.updateSubstate(SubState.layer2, layer2)
			.build()
		
		initialState = TreeState<Int>.builder()
			.updateSubstate(SubState.layer1, layer1)
			.build()
		
		store = RxReduxStore<Int>.createInstance(initialState!, reduce)
	}
	
	fileprivate func reduce(_ state: TreeState<Int>, _ action: ReduxActionType) -> TreeState<Int> {
		switch action {
		case let action as Action:
			let updateFn = action.updateFn()
			return state.map(updateId, updateFn)
			
		default:
			return state
		}
	}
	
	public func test_dispatchAction_shouldUpdateState() {
		/// Setup
		let stateObs = scheduler.createObserver(TreeState<Int>.self)
		let valueObs = scheduler.createObserver(Try<Int>.self)
		let store = self.store!
		var original = 0
		let times = 1000
		
		store.stateStream()
			.subscribe(stateObs)
			.disposed(by: disposeBag)
		
		store.stateValueStream(Int.self, updateId)
			.subscribe(valueObs)
			.disposed(by: disposeBag)
		
		/// When
		for _ in 0..<times {
			let action = Action.randomValue()!
			original = action.updateFn()(Try.success(original)).value!
			store.dispatch(action)
		}
		
		/// Then
		let nextStateElements = stateObs.nextElements()
		let nextValueElements = valueObs.nextElements()
		XCTAssertTrue(nextStateElements.isNotEmpty)
		XCTAssertTrue(nextValueElements.isNotEmpty)
		
		let state = nextStateElements.last!
		let value = nextValueElements.last!.value!
		let currentValue = state.stateValue(updateId).value!
		XCTAssertEqual(currentValue, original)
		XCTAssertEqual(currentValue, value)
	}
}
