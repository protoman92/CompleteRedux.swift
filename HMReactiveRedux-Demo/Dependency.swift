//
//  Dependency.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import HMReactiveRedux
import HMReactiveReduxUI
import SafeNest

struct Dependency {
  private static var _instance: Dependency?
  
  static var instance: Dependency {
    if let instance = self._instance {
      return instance
    } else {
      let instance = Dependency()
      self._instance = instance
      return instance
    }
  }
  
  let store: RxReduxStore<SafeNest>
  let connector: ReduxConnector<RxReduxStore<SafeNest>>
  
  private init() {
    let initial = SafeNest.empty()
    self.store = RxReduxStore.create(initial, Redux.Reducer.main)
    self.connector = ReduxConnector(store: self.store)
  }
}
