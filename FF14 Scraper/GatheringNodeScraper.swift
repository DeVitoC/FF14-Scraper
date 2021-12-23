//
//  GatheringNodeScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/21/21.
//

import Foundation
import SwiftSoup

class GatheringNodeScraper {
    var nodesToSearch: [String: String] = [:]
    var nodes: [GatheringNode] = []
    typealias GatheringNodeDictionary = [String: GatheringNode]
    let locations = ["Limsa Lominsa Upper Decks", "Limsa Lominsa Lower Decks", "Eastern La Noscea", "Lower La Noscea", "Middle La Noscea", "Upper La Noscea", "Western La Noscea", "Outer La Noscea", "New Gridania", "Old Gridania", "Central Shroud", "East Shroud", "North Shroud", "South Shroud", "Central Thanalan", "Eastern Thanalan", "Northern Thanalan", "Southern Thanalan", "Western Thanalan", "The Lavender Beds", "Coerthas Central Highlands", "Coerthas Western Highlands", "Mor Dhona", "Mists", "Labender Beds", "The Dravanian Forelands", "The Dravanian Hinterlands", "The Churning Mists", "The Sea of Clouds", "The Fringes", "The Peaks", "The Ruby Sea", "The Azim Steppe", "Yanxia", "The Lochs", "Amh Araeng", "Lakeland", "Kholusia", "Il Mheg", "The Rak'tika Greatwood", "Labyrinthos", "Thavnair", "Garlemald", "Azys Lla", "The Tempest", "Rhalgr's Reach"]

    func scrapeGatheringNodesWiki() throws {
        guard let consoleGamesWikiURL = URL(string: "https://ffxiv.consolegameswiki.com"), let gamerEscapeWikiURL = URL(string: "https://ffxiv.gamerescape.com") else { return }
        let GatheringNode = try scrapeGatheringNodes(consoleGamesURL: consoleGamesWikiURL, gamerEscapeURL: gamerEscapeWikiURL)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(GatheringNode)
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/botanyNodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }

    private func scrapeGatheringNodes(consoleGamesURL: URL, gamerEscapeURL: URL) throws -> [String: String] {
        let testItem = "/wiki/Ebony_Log"
        let testItemName = "Ebony Log"
        let consoleGamesWikiItemURL = consoleGamesURL.appendingPathComponent(testItem)
        let consoleGamesHTML = try String(contentsOf: consoleGamesWikiItemURL)
        let consoleGamesDocument = try SwiftSoup.parse(consoleGamesHTML)
//        let gamerEscapeWikiItemURL = gamerEscapeURL.appendingPathComponent(testItem)
//        let gamerEscapeHTML = try String(contentsOf: gamerEscapeWikiItemURL)
//        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)
             
        guard let h1 = try consoleGamesDocument.select("#firstHeading").first(), let div = try consoleGamesDocument.select("#mw-content-text").first() else { return [:] }
//        guard let div = try document.select("#mw-content-text").first(),
//                let divChild = div.children().first(),
//                let divGrandchild = try divChild.children().first()?.nextElementSibling(),
//                let divGGrandchild = divGrandchild.children().first(),
//                let divGGGrandchild = divGGrandchild.children().first() else { return [:] }
//
//        var element = divGGGrandchild
        print(div)

        var nodeNames: [String: String] = [:]

        let itemName = try h1.text()

//        while true {
//            guard let sibling = try element.nextElementSibling() else { break }
//            switch sibling.tagName() {
//            case "hr":
//                // We know the first hr comes after the end of the table
//                return nodeNames
//            case "tr":
//                // This is the table entry with our information
//                let siblingChildren = sibling.children()
//
//                for tableEntry in siblingChildren {
//                    print()
//                    let nodeEntries = tableEntry.children()
//                    for entry in nodeEntries {
//                        guard let name = try? entry.text() else { continue }
//                        let href = try entry.attr("href")
//                        if locations.contains(name) || nodeTypes.contains(name) {
//                            continue
//                        }
//                        nodeNames[name] = href
//                    }
//                }
//            default:
//                print(sibling)
//            }
//            element = sibling
//        }
        return nodeNames
    }
}
