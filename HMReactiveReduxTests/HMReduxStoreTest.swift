//
//  HMReduxStoreTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import RxTest
import RxSwift
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

public enum Action: HMActionType, EnumerableType {
    case add
    case addTwo
    case addThree
    case minus
    
    public static func allValues() -> [Action] {
        return [add, addTwo, addThree, minus]
    }
    
    public func updateFn() -> HMState.UpdateFn<Int> {
        switch self {
        case .add: return {$0 + 1}
        case .addTwo: return {$0 + 2}
        case .addThree: return {$0 + 3}
        case .minus: return {$0 - 1}
        }
    }
}

public final class HMReduxStoreTest: XCTestCase {
    fileprivate var disposeBag: DisposeBag!
    fileprivate var scheduler: TestScheduler!
    fileprivate var initialState: HMState!
    fileprivate var store: HMReduxStore<Action,HMState>!
    
    fileprivate var updateId: String {
        return "layer1.layer2.layer3.calculation"
    }
    
    override public func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        let layer3 = HMState.builder()
            .updateState(State.calculation, 0)
            .build()
        
        let layer2 = HMState.builder()
            .updateSubstate(SubState.layer3, layer3)
            .build()
        
        let layer1 = HMState.builder()
            .updateSubstate(SubState.layer2, layer2)
            .build()
        
        initialState = HMState.builder()
            .updateSubstate(SubState.layer1, layer1)
            .build()
        
        store = HMReduxStore<Action,HMState>.mainThreadVariant(initialState!, reduce)
    }
    
    fileprivate func reduce(_ state: HMState, _ action: Action) -> HMState {
        let updateFn = action.updateFn()
        return state.mapValue(updateId, updateFn)
    }
    
    public func test_dispatchAction_shouldUpdateState() {
        /// Setup
        let stateObs = scheduler.createObserver(HMState.self)
        let store = self.store!
        var original = 0
        let times = 1000
        
        store.stateStream()
            .subscribe(stateObs)
            .disposed(by: disposeBag)
        
        /// When
        for _ in 0..<times {
            let action = Action.randomValue()!
            original = action.updateFn()(original)
            store.dispatch(action)
        }
        
        /// Then
        let nextElements = stateObs.nextElements()
        XCTAssertTrue(nextElements.isNotEmpty)
        
        let state = nextElements.last!
        let currentValue = state.stateValue(updateId) as! Int
        XCTAssertEqual(currentValue, original) 
    }
}
