//
//  Dependency.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import CompleteRedux

public final class Dependency {
  let propInjector: PropInjector<AppState>
  let store: DelegateStore<AppState>
  
  public init(store: DelegateStore<AppState>) {
    self.store = store
    self.propInjector = PropInjector(store: self.store)
  }
}
