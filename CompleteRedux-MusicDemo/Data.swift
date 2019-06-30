//
//  Data.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/10/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public struct iTunesTrack {
  let artistName: String
  let currency: String
  let previewUrl: String
  let trackName: String
  let trackPrice: Double
  let trackTimeMillis: Int
}

public struct iTunesResult {
  let resultCount: Int
  let results: [iTunesTrack]
}

// MARK: - Equatable
extension iTunesTrack: Equatable {}

// MARK: - Decodable
extension iTunesTrack: Decodable {}

// MARK: - Equatable
extension iTunesResult: Equatable {}

// MARK: - Decodable
extension iTunesResult: Decodable {}
