//
//  FishingNodeWC.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/17/22.
//

import Foundation

struct FishingNodeWC: Node {
    var name: String
    let time: Int?
    let duration: Int
    let location: String
    let img: String
    var description: String
    let type: String
    let source: String
    let lvl: Int
    let stars: Int
    let x: Int
    let y: Int
    var expac: Int
    let desynthLvl: Int
    let desynthJob: String
    let mooch: Bool
    let moochFrom: [String]
    let isWeatherChain: Bool
    let weather: [String] // if is a weather chain, this is the weather(s) the fish is actually available in
    let weatherChain: [String] // the weather leading up to the weather
    let waterType: String
}
