//
//  Dependency.swift
//  SwiftRedux-Demo
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux
import SafeNest

struct Dependency {
  let store: DelegateStore<SafeNest>
  let injector: PropInjector<SafeNest>
  
  init(_ navController: UINavigationController) {
    let initial = try! SafeNest.empty()
      .encoding(at: AppRedux.Path.rootPath, value: ViewController1.State(
        number: 0,
        slider: 0,
        string: nil,
        textIndexes: (0..<5).map({$0}),
        texts: (0..<5).map({["\($0)" : ""]})
          .reduce([:], {$0!.merging($1, uniquingKeysWith: {$1})}),
        progress: false
      ))
    
    let router = ReduxRouter(navController)
    
    self.store = applyMiddlewares([
      RouterMiddleware(router: router).middleware,
      SagaMiddleware(effects: AppReduxSaga.sagas()).middleware
      ])(SimpleStore.create(initial, AppRedux.Reducer.main))
    
    self.injector = PropInjector(store: self.store)
  }
}
