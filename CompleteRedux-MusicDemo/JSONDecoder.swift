//
//  JSONDecoder.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/10/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import Foundation

/// Use this protocol to represent a JSON decoder.
public protocol JSONDecoderType {
  func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable
}

// MARK: - JSONDecoderType
extension JSONDecoder: JSONDecoderType {}
