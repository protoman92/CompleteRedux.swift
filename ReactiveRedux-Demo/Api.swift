//
//  Api.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import RxSwift

final class Api {
  static func performAutocomplete(_ input: String) -> Observable<[String]> {
    return Observable.just(())
      .delay(2, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
      .map({_ in (0...3).map({"Autocompleted \(input): \($0)"})})
  }
}
