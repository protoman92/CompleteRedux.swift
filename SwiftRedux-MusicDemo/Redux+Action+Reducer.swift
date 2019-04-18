//
//  Redux+Action+Reducer.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux

public struct AppState {
  var autocompleteInput: String?
  var autocompleteProgress: Bool?
  var counter: Int
  var iTunesResults: iTunesResult?
  var textValueList: [String?]
  
  public init() {
    self.counter = 0
    self.textValueList = []
  }
  
  public func increment() -> AppState {
    var clone = self
    clone.counter += 1
    return clone
  }
  
  public func updateTextValue(_ index: Int, _ value: String?) -> AppState {
    var clone = self
    let length = self.textValueList.count
    
    if index >= 0 && index < length {
      clone.textValueList[index] = value
    } else if index >= length {
      clone.textValueList.append(value)
    }
    
    return clone
  }
  
  public func updateAutocompleteInput(_ input: String?) -> AppState {
    var clone = self
    clone.autocompleteInput = input
    return clone
  }
  
  public func updateAutocompleteProgress(_ progress: Bool?) -> AppState {
    var clone = self
    clone.autocompleteProgress = progress
    return clone
  }
  
  public func updateITunesResults(_ results: iTunesResult?) -> AppState {
    var clone = self
    clone.iTunesResults = results
    return clone
  }
  
  public func iTunesTrack(at index: Int) -> iTunesTrack? {
    if
      let tracks = self.iTunesResults?.results,
      index >= 0 && index < tracks.count
    {
      return tracks[index]
    } else {
      return nil
    }
  }
}

public enum AppAction: ReduxActionType {
  case incrementCounter
  case updateTextValue(Int, String?)
  case updateAutocompleteInput(String?)
  case updateAutocompleteProgress(Bool?)
  case updateITunesResults(iTunesResult?)
}

// MARK: - Equatable
extension AppAction: Equatable {}

public final class AppReducer {
  public static func reduce(_ state: AppState, _ action: ReduxActionType) -> AppState {
    switch action {
    case let action as AppAction:
      switch action {
      case .incrementCounter:
        return state.increment()

      case .updateTextValue(let index, let value):
        return state.updateTextValue(index, value)
        
      case .updateAutocompleteInput(let input):
        return state.updateAutocompleteInput(input)
        
      case .updateAutocompleteProgress(let progress):
        return state.updateAutocompleteProgress(progress)
        
      case .updateITunesResults(let results):
        return state.updateITunesResults(results)
      }
      
    default: return state
    }
  }
}
