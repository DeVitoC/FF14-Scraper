//
//  FishingNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class FishingNodeFolkloreScraper {
    var nodes: [String: String] = [:]
    typealias BotanyNodeDictionary = [String: GatheringNode]
    let nodeTypes = ["Mature Tree", "Lush Vegetation Patch"]
    let locations = ["Limsa Lominsa Upper Decks", "Limsa Lominsa Lower Decks", "Eastern La Noscea", "Lower La Noscea", "Middle La Noscea", "Upper La Noscea", "Western La Noscea", "Outer La Noscea", "New Gridania", "Old Gridania", "Central Shroud", "East Shroud", "North Shroud", "South Shroud", "Central Thanalan", "Eastern Thanalan", "Northern Thanalan", "Southern Thanalan", "Western Thanalan", "The Lavender Beds", "Coerthas Central Highlands", "Coerthas Western Highlands", "Mor Dhona", "Mists", "Labender Beds", "The Dravanian Forelands", "The Dravanian Hinterlands", "The Churning Mists", "The Sea of Clouds", "The Fringes", "The Peaks", "The Ruby Sea", "The Azim Steppe", "Yanxia", "The Lochs", "Amh Araeng", "Lakeland", "Kholusia", "Il Mheg", "The Rak'tika Greatwood", "Labyrinthos", "Thavnair", "Garlemald", "Azys Lla", "The Tempest", "Rhalgr's Reach"]

    func scrapeFishingNodesWiki() throws {
        let botanistNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Folklore_Nodes")!
        let botanyNodes = try scrapeFishingNodes(url: botanistNodesURL)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(botanyNodes)
        let jsonString = String(decoding: json, as: UTF8.self)
        
        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/FishingNodesFolklore.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    
    private func scrapeFishingNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)

        guard let span = try document.select("#Fisher").first(),
              let h2 = span.parent(),
              let table = try h2.nextElementSibling(),
              let tbody = table.children().first() else { print( "no span found"); return [:] }
        
        var element = tbody

        var nodeNames: [String: String] = [:]

        for sibling in element.children() {
            for child in sibling.children() {
                switch child.tagName() {
                case "hr":
                    // We know the first hr comes after the end of the table
                    return nodeNames
                case "td":
                    // This is the table entry with our information
                    guard let a = child.children().first() else { continue }
                    guard let name = try? a.text() else { continue }
                    let href = try a.attr("href")
                    if locations.contains(name) || nodeTypes.contains(name) {
                        continue
                    }
                    nodeNames[name] = href
                default:
                    continue
                }
            }
            element = sibling
        }
        return nodeNames
    }
}
