//
//  Redux+MockProps.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/11/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

extension Redux.UI {

  /// Use this mock static props for testing:
  ///
  ///     let staticProps = MockStaticProps(...)
  ///     vc.staticProps = staticProps
  ///
  public final class MockStaticProps<State>: StaticProps<State> {

    /// This initializer can be used to construct test static props.
    convenience public init(injector: Redux.UI.PropInjector<State>) {
      self.init(injector, Redux.Store.Subscription({}))
    }
  }
}
