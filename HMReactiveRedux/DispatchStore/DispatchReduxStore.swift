//
//  DispatchReduxStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Convenience class to get around Swift's generic constraints. Other stores
/// should extend from this.
public class DispatchReduxStore<State, RegistryInfo, CBValue> {
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Element == Action {
    fatalError("Must override this")
  }

  public func lastState() -> State {
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
