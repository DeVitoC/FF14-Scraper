//
//  FishingNode.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation

struct FishingNode: Node {
    let name: String
    let time: Int?
    let duration: Int
    let location: String
    let img: String
    let description: String
    let type: String
    let source: String
    let lvl: Int
    let stars: Int
    let x: Int
    let y: Int
    let expac: Int
    let desynthLvl: Int
    let desynthJob: String
    let mooch: Bool
    let moochFrom: [String]
    let weather: [String]
    let waterType: String
    let gathering: Int
}

enum Weather: String {
    case clear, clouds, blizzard, dustStorm, fair
    case fog, gales, gloom, heatWaves, rain
    case showers, snow, thunder, thunderstorms, umbralStatic
    case umbralWind, wind, any
}
