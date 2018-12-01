//
//  ReduxAction.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
@testable import ReactiveRedux

public enum Action: CaseIterable, ReduxActionType {
  case add
  case addTwo
  case addThree
  case minus

  public static func allValues() -> [Action] {
    return [add, addTwo, addThree, minus]
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
