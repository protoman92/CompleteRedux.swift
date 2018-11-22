//
//  Redux.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 11/22/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import HMReactiveRedux
import SafeNest

public final class DataObjectRedux {
  public final class Path {
    public static var rootPath: String {
      return "main"
    }
    
    public static var numberPath: String {
      return "\(Path.rootPath).number"
    }
    
    public static var stringPath: String {
      return "\(Path.rootPath).string"
    }
    
    public static var sliderPath: String {
      return "\(Path.rootPath).slider"
    }
  }
  
  public enum ClearAction: ReduxActionType {
    case triggerClear
    case resetClear
    
    public static var path: String {
      return "clear"
    }
    
    public static var clearPath: String {
      return "\(path).value"
    }
  }
  
  public enum NumberAction: ReduxActionType {
    case add
    case minus
  }
  
  public enum StringAction: ReduxActionType {
    case input(String)
  }
  
  public enum SliderAction: ReduxActionType {
    case input(Double)
    
  }
  
  public static func reduceMain(_ state: SafeNest, _ action: ReduxActionType) -> SafeNest {
    switch action {
    case let action as ClearAction: return reduceClear(state, action)
    case let action as NumberAction: return reduceNumber(state, action)
    case let action as StringAction: return reduceString(state, action)
    case let action as SliderAction: return reduceSlider(state, action)
    default: return state
    }
  }
  
  static func reduceClear(_ state: SafeNest, _ action: ClearAction) -> SafeNest {
    switch action {
    case .triggerClear:
      return try! state
        .updating(at: Path.numberPath, value: nil)
        .updating(at: Path.stringPath, value: nil)
        .updating(at: Path.sliderPath, value: nil)
        .updating(at: ClearAction.clearPath, value: true)
      
    case .resetClear:
      return try! state.updating(at: ClearAction.clearPath, value: nil)
    }
  }
  
  static func reduceNumber(_ state: SafeNest, _ action: NumberAction) -> SafeNest {
    switch action {
    case .add:
      return try! state.mapping(at: Path.numberPath, withMapper: {
        return $0.cast(Int.self).someOrElse(Optional.some(0)).map({$0 + 1})
      })
      
    case .minus:
      return try! state.mapping(at: Path.numberPath, withMapper: {
        return $0.cast(Int.self).someOrElse(Optional.some(0)).map({$0 - 1})
      })
    }
  }
  
  static func reduceString(_ state: SafeNest, _ action: StringAction) -> SafeNest {
    switch action {
    case .input(let string):
      return try! state.updating(at: Path.stringPath, value: string)
    }
  }
  
  static func reduceSlider(_ state: SafeNest, _ action: SliderAction) -> SafeNest {
    switch action {
    case .input(let value):
      return try! state.updating(at: Path.sliderPath, value: value)
    }
  }
}

