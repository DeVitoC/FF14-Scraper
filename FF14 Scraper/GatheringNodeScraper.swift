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
    let type = ["Submersible Components", "Bone", "Cloth", "Dye", "Ingredient", "Leather", "Lumber", "Metal", "Part", "Reagent", "Seafood", "Stone"]

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
        
        // get item name
        guard let h1 = try consoleGamesDocument.select("#firstHeading").first() else { return [:] }
        let itemName = try h1.text()
        
        // get item description
        guard let div = try consoleGamesDocument.select("#mw-content-text").first(),
              let div2 = div.children().first(), let div3 = div2.children().first(),
              let blockquote = try div3.nextElementSibling() else { return [:] }
        var itemDescription = try blockquote.text()
        itemDescription.removeFirst()
        itemDescription.removeFirst()
        itemDescription.removeSubrange(String.Index(utf16Offset: itemDescription.count - 22, in: itemDescription)...String.Index(utf16Offset: itemDescription.count - 1, in: itemDescription))
        
        // get item type
//        let divChildren = div3.children()
//        for child in div3.children() {
//            if try child.tagName() == "p" || child.text() == "" || child.text() == "." || child.text() == " " {
//                continue
//            } else {
//
//                print(try child.text())
//            }
//        }
        
        // get item level
        guard let gatheringSpan = try consoleGamesDocument.select("#Gathered").first(), let gatheringH3 = gatheringSpan.parent(), let gatheringP = try gatheringH3.nextElementSibling() else { return [:] }
        
        
        print(try gatheringP.text())

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
        return [:]
    }
}
