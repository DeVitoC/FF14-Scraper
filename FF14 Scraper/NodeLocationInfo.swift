//
//  NodeLocationInfo.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/26/21.
//

import Foundation

struct NodeLocationInfo: LocationInfo {
    let time: Int?
    let location: String
    let source: String
    let stars: Int
    let x: Int
    let y: Int
}

protocol LocationInfo {
    var time: Int? { get }
    var location: String { get }
    var source: String { get }
    var stars: Int { get }
    var x: Int { get }
    var y: Int { get }
}
