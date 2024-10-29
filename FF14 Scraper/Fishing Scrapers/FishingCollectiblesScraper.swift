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
    let locations = locationStrings
    
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
