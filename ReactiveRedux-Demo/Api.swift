//
//  Api.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import RxSwift

final class Api {
  static func performAutocomplete(_ input: String) -> Observable<[String]> {
    if Bool.random() {
      return Observable.error(Redux.Saga.Error.unimplemented)
    }
    
    return Observable.just(())
      .delay(0.5, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
      .map({_ in (0...3).map({"Autocompleted \(input): \($0)"})})
  }
}
