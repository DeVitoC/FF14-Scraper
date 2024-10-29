//
//  FishingNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/19/21.
//

import Foundation
import SwiftSoup

class FishingNodesScraper {
    var nodes: [String: String] = [:]
    typealias FishingNodeDictionary = [String: FishingNode]
    let bait = ["Pill Bug", "Lugworm", "Bloodworm", "Crayfish Ball", "Butterworm", "Crow Fly", "Rat Tail", "Midge Basket", "Spinnerbait", "Crab Ball", "Floating Minnow", "Spoon Worm", "Sinking Minnow", "Goby Ball", "Northern Krill", "Yumizuno", "Glowworm", "Krill Cage Feeder", "Steel Jig", "Heavy Steel Jig", "Bass Ball", "Moth Pupa", "Brass Spoon Lure", "Saltwater Boilie", "Mythril Spoon Lure", "Syrphid Basket", "Freshwater Boilie", "Sand Gecko", "Sand Leech", "Chocobo Fly", "Stem Borer", "Topwater Frog", "Hoverworm"]
    let locations = locationStrings
    
    func scrapeFishingNodesWiki() throws {
        let FishingNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Fishing_Locations")!
        let FishingNodes = try scrapeFishingNodes(url: FishingNodesURL)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(FishingNodes)
        let jsonString = String(decoding: json, as: UTF8.self)
        
        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/FishingNodesNormal.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeFishingNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)
        
        guard let span = try document.select("#Limsa_Lominsa_Upper_Decks").first(),
              let h3 = span.parent(),
              let div = h3.parent() else { return [:] }
        let divChildren = div.children()
        
        var nodeNames: [String: String] = [:]
        
        for child in divChildren where child.tagName() == "table" {
            guard let tbody = child.children().first() else { return [:] }
            for tr in tbody.children() {
                for td in tr.children() where td.tagName() != "th" {
                    for tableEntry in td.children() {
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
