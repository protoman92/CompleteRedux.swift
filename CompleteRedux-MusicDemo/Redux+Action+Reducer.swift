//
//  Redux+Action+Reducer.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import CompleteRedux

public struct AppState {
  var autocompleteInput: String?
  var autocompleteProgress: Bool?
  var iTunesResults: iTunesResult?
  
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
