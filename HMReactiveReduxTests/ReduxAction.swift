//
//  ReduxAction.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
@testable import HMReactiveRedux

public enum Action: CaseIterable, ReduxActionType {
  case add
  case addTwo
  case addThree
  case minus

  public static func allValues() -> [Action] {
    return [add, addTwo, addThree, minus]
  }

  public func updateFn() -> (Int) -> Int {
    switch self {
    case .add: return {$0 + 1}
    case .addTwo: return {$0 + 2}
    case .addThree: return {$0 + 3}
    case .minus: return {$0 - 1}
    }
  }

  public func stateUpdateFn() -> (Any) -> Any {
    return {
      let value = $0 as! Int
      
      switch self {
      case .add: return value + 1
      case .addTwo: return value + 2
      case .addThree: return value + 3
      case .minus: return value - 1
      }
    }
  }
}
