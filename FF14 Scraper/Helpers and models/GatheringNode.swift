//
//  GatheringNode.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation

struct GatheringNode: Node {
    var name: String
    let time: Int?
    let location: String
    let img: String
    var description: String
    let type: String
    let lvl: Int
    let stars: Int
    let x: Int
    let y: Int
    var expac: Int
}
