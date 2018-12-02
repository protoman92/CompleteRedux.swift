//
//  Dependency.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import SafeNest

struct Dependency {
  private static var _instance: Dependency?
  
  static var shared: Dependency {
    if let instance = self._instance {
      return instance
    } else {
      let instance = Dependency()
      self._instance = instance
      return instance
    }
  }
  
  let store: Redux.EnhancedStore<SafeNest>
  let injector: Redux.PropInjector<SafeNest>
  
  private init() {
    let initial = try! SafeNest.empty()
      .encoding(at: AppRedux.Path.rootPath, value: ViewController.StateProps(
        number: 0,
        slider: 0,
        string: nil,
        textIndexes: (0..<5).map({$0}),
        texts: (0..<5).map({["\($0)" : ""]})
          .reduce([:], {$0!.merging($1, uniquingKeysWith: {$1})})
      ))
    
    self.store = Redux.applyMiddlewares()(
      Redux.RxStore.create(initial, AppRedux.Reducer.main)
    )
    
    self.injector = Redux.PropInjector(store: self.store)
  }
}
