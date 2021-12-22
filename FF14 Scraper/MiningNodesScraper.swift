//
//  MiningNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/19/21.
//

import Foundation
import SwiftSoup

class MiningNodeScraper {
    var nodes: [String: String] = [:]
    typealias FishingNodeDictionary = [String: GatheringNode]
    let nodeTypes = ["Rocky Outcrop", "Mineral Deposit"]
    let locations = ["Limsa Lominsa Upper Decks", "Limsa Lominsa Lower Decks", "Eastern La Noscea", "Lower La Noscea", "Middle La Noscea", "Upper La Noscea", "Western La Noscea", "Outer La Noscea", "New Gridania", "Old Gridania", "Central Shroud", "East Shroud", "North Shroud", "South Shroud", "Central Thanalan", "Eastern Thanalan", "Northern Thanalan", "Southern Thanalan", "Western Thanalan", "The Lavender Beds", "Coerthas Central Highlands", "Coerthas Western Highlands", "Mor Dhona", "Mists", "Labender Beds", "The Dravanian Forelands", "The Dravanian Hinterlands", "The Churning Mists", "The Sea of Clouds", "The Fringes", "The Peaks", "The Ruby Sea", "The Azim Steppe", "Yanxia", "The Lochs", "Amh Araeng", "Lakeland", "Kholusia", "Il Mheg", "The Rak'tika Greatwood", "Labyrinthos", "Thavnair", "Garlemald", "Azys Lla", "The Tempest", "Rhalgr's Reach"]
    
    func scrapeMiningNodesWiki() throws {
        let miningNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Mining_Node_Locations")!
        let miningNodes = try scrapeMiningNodes(url: miningNodesURL)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(miningNodes)
        let jsonString = String(decoding: json, as: UTF8.self)
        
        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/MiningNodesNormal.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeMiningNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)
        
        guard let div = try document.select("#mw-content-text").first(),
              let divChild = div.children().first(),
              let hr = try divChild.children().first()?.nextElementSibling(),
              let table = try hr.nextElementSibling(),
              let tbody = table.children().first() else { return [:] }
        let tbodyChildren = tbody.children()
        var nodeNames: [String: String] = [:]
        
        for tr in tbodyChildren {
            for child in tr.children() {
                if child.tagName() == "th" {
                    continue
                }
                for tableEntry in child.children() {
                    guard let name = try? tableEntry.text() else { continue }
                    let href = try tableEntry.attr("href")
                    if locations.contains(name) || nodeTypes.contains(name) {
                        continue
                    }
                    nodeNames[name] = href
                }
            }
        }
        return nodeNames
    }
}
