//
//  FishingNodeLocationInfo.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 1/20/22.
//

import Foundation

struct FishingNodeLocationInfo: LocationInfo {
    var time: Int?
    var location: String
    var source: String
    var stars: Int
    var x: Int
    var y: Int
    var duration: Int
    var weather: [String]
    var mooch: Bool
    var bait: [String]
    var waterType: String
}
