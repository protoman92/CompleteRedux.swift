//
//  LastActionStoreTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import HMReactiveRedux

public enum PingAction: ReduxActionType {
  case action1
  case clearAction1
}

public enum NormalAction: ReduxActionType {
  case action2
}

public final class InvalidState {}

public final class LastActionState: PingActionCheckerType {
  public var pingActionState: Bool?
  public var normalActionState: Bool?
  
  public func set(pingActionState: Bool?) -> LastActionState {
    let state1 = LastActionState()
    state1.pingActionState = pingActionState
    state1.normalActionState = normalActionState
    return state1
  }
  
  public func set(normalActionState: Bool?) -> LastActionState {
    let state1 = LastActionState()
    state1.pingActionState = pingActionState
    state1.normalActionState = normalActionState
    return state1
  }
  
  public func checkPingActionCleared(_ action: ReduxActionType) -> Bool {
    switch action {
    case let action as PingAction:
      switch action {
      case .action1: return pingActionState == nil
      default: break
      }
      
    default:
      break
    }
    
    return true
  }
}

public final class InvalidStoreReducer {
  public static func main(_ state: InvalidState, _ action: ReduxActionType)
    -> InvalidState
  {
    return state
  }
}

public final class LastActionReducer {
  public static func main(_ state: LastActionState, _ action: ReduxActionType)
    -> LastActionState
  {
    switch action {
    case let action as PingAction:
      switch action {
      case .action1: return state.set(pingActionState: true)
      case .clearAction1: return state.set(pingActionState: nil)
      }
      
    case let action as NormalAction:
      switch action {
      case .action2: return state.set(normalActionState: true)
      }
      
    default: return state
    }
  }
}

public final class LastActionStoreTest: XCTestCase {
  public var invalidStore: GenericDispatchStore<InvalidState>!
  public var validStore: GenericDispatchStore<LastActionState>!
  
  override public func setUp() {
    super.setUp()
    continueAfterFailure = true
    let queue = DispatchQueue.main
    
    let initValid = LastActionState()
    validStore = GenericDispatchStore(initValid, LastActionReducer.main, queue)
    
    let initInvalid = InvalidState()
    invalidStore = GenericDispatchStore(initInvalid, InvalidStoreReducer.main, queue)
  }
  
  public func test_dispatchPingAction_shouldPerformCheck() {
    /// Setup
    var notifyCount = 0
    let issueNotifier: (String) -> Void = {_ in notifyCount += 1}
    let lastActionStore = LastActionDispatchStore(validStore!, issueNotifier)

    /// When
    lastActionStore.dispatch(PingAction.action1)
    lastActionStore.dispatch(NormalAction.action2)

    /// Then
    XCTAssertEqual(notifyCount, 1)
  }
  
  public func test_dispatchPingActionWithInvalidStore_shouldNotify() {
    /// Setup
    var notifyCount = 0
    let issueNotifier: (String) -> Void = {_ in notifyCount += 1}
    let invalidStore = LastActionDispatchStore(self.invalidStore!, issueNotifier)
    
    /// When
    invalidStore.dispatch(NormalAction.action2)
    
    /// Then
    XCTAssertEqual(notifyCount, 1)
  }
}
