//
//  Api.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/10/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import Foundation

public protocol AppAPIType {
  func searchITunes(_ input: String, _ cb: @escaping (Data?, Error?) -> Void)
}

public struct AppAPI: AppAPIType {
  private let _urlSession: URLSession
  
  public init(_ urlSession: URLSession) {
    self._urlSession = urlSession
  }
  
  public func searchITunes(_ input: String, _ cb: @escaping (Data?, Error?) -> Void) {
    var comps = URLComponents(string: "https://itunes.apple.com/search")!
    
    comps.queryItems = [
      URLQueryItem(name: "term", value: input),
      URLQueryItem(name: "limit", value: "5"),
      URLQueryItem(name: "media", value: "music")
    ]
    
    let task = self._urlSession.dataTask(with: comps.url!) {cb($0, $2)}
    task.resume()
  }
}
