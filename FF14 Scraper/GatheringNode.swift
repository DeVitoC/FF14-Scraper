//
//  GatheringNode.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation

struct GatheringNode: Node {
    let name: String
    let time: Int?
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
    let gathering: Int
}
