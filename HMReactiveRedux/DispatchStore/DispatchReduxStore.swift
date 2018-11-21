//
//  DispatchReduxStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

/// Convenience class to get around Swift's generic constraints. Other stores
/// should extend from this.
open class DispatchReduxStore<State, RegistryInfo, CBValue> {
  public var lastState: Try<State> {
    fatalError("Must override this")
  }
  
  public func dispatch(_ actions: Action) {
    fatalError("Must override this")
  }

  public func register(_ info: RegistryInfo, _ callback: @escaping ReduxCallback<CBValue>) {
    fatalError("Must override this")
  }

  public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String {
    fatalError("Must override this")
  }
}

extension DispatchReduxStore: DispatchReduxStoreType {}
