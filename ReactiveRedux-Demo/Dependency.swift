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
  let store: Redux.DelegateStore<SafeNest>
  let injector: Redux.PropInjector<SafeNest>
  
  init(_ navController: UINavigationController) {
    let initial = try! SafeNest.empty()
      .encoding(at: AppRedux.Path.rootPath, value: ViewController1.StateProps(
        number: 0,
        slider: 0,
        string: nil,
        textIndexes: (0..<5).map({$0}),
        texts: (0..<5).map({["\($0)" : ""]})
          .reduce([:], {$0!.merging($1, uniquingKeysWith: {$1})})
      ))
    
    let router = ReduxRouter(navController)
    
    self.store = Redux.applyMiddlewares(
      Redux.RouterMiddleware(router).wrap)(
      Redux.RxStore.create(initial, AppRedux.Reducer.main)
    )
    
    self.injector = Redux.PropInjector(store: self.store)
  }
}
