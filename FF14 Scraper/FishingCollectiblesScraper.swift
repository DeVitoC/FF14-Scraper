//
//  FishingCollectiblesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/20/21.
//

import Foundation
import SwiftSoup

class FishingCollectiblesScraper {
    var nodes: [String: String] = [:]
    typealias FishingNodeDictionary = [String: FishingNode]
    let bait = ["Caddisfly Larva", "Purse Web Spider", "Stonefly Nymph", "Balloon Bug", "Goblin Jig", "Bladed Steel Jig", "Brute Leech", "Blueclaw Shrimp", "Hedgemole Cricket", "Sweetfish", "Bullfrog"]
    let locations = ["Limsa Lominsa Upper Decks", "Limsa Lominsa Lower Decks", "Eastern La Noscea", "Lower La Noscea", "Middle La Noscea", "Upper La Noscea", "Western La Noscea", "Outer La Noscea", "New Gridania", "Old Gridania", "Central Shroud", "East Shroud", "North Shroud", "South Shroud", "Central Thanalan", "Eastern Thanalan", "Northern Thanalan", "Southern Thanalan", "Western Thanalan", "The Lavender Beds", "Coerthas Central Highlands", "Coerthas Western Highlands", "Mor Dhona", "Mists", "Labender Beds", "The Dravanian Forelands", "The Dravanian Hinterlands", "The Churning Mists", "The Sea of Clouds", "The Fringes", "The Peaks", "The Ruby Sea", "The Azim Steppe", "Yanxia", "The Lochs", "Amh Araeng", "Lakeland", "Kholusia", "Il Mheg", "The Rak'tika Greatwood", "Labyrinthos", "Thavnair", "Garlemald", "Azys Lla", "The Tempest", "Rhalgr's Reach", "South Banepool", "Unfrozen Pond", "Weston Waters", "Voor Sian Siran", "Eil Tohm", "Greytail Falls", "Whilom River", "The Smouldering Wastes", "Thaliak River", "The Pappus Tree", "The Iron Feast", "????"]
    
    func scrapeFishingCollectiblesWiki() throws {
        let FishingCollectiblesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Fishing_Collectables")!
        let FishingNodes = try scrapeFishingNodes(url: FishingCollectiblesURL)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(FishingNodes)
        let jsonString = String(decoding: json, as: UTF8.self)
        
        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/FishingCollectiblesNormal.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeFishingNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)
        
        guard let div = try document.select("#mw-content-text").first(),
              let divChild = try div.children().first() else { return [:] }
        
        let divChildren = divChild.children()
        
        var nodeNames: [String: String] = [:]
        
        for child in divChildren where child.tagName() == "table" {
            guard let tbody = child.children().first() else { return [:] }
            for tr in tbody.children() {
                for td in tr.children() where td.tagName() != "th" {
                    for tableEntry in td.children() where tableEntry.tagName() == "a" {
                        guard let name = try? tableEntry.text() else { continue }
                        let href = try tableEntry.attr("href")
                        guard !href.isEmpty else { continue }
                        if locations.contains(name) || bait.contains(name) {
                            continue
                        }
                        nodeNames[name] = href
                    }
                }
            }
        }
        return nodeNames
    }
}
