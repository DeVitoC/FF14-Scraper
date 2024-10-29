//
//  MiningNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/19/21.
//

import Foundation
import SwiftSoup

class MiningNodesScraper {
    var nodes: [String: String] = [:]
    typealias FishingNodeDictionary = [String: GatheringNode]
    let nodeTypes = ["Rocky Outcrop", "Mineral Deposit"]
    let locations = locationStrings
    
    func scrapeMiningNodesWiki() throws {
        let miningNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Miner_Node_Locations")!
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
              let parserDiv = div.children().first(),
              let dividerHR = try parserDiv.children().first()?.nextElementSibling(),
              let table = try dividerHR.nextElementSibling(),
              let tBody = table.children().first(),
              let tableRow = tBody.children().first()
        else { return [:] }


        var element = tableRow

        var nodeNames: [String: String] = [:]

        while true {
            guard let sibling = try element.nextElementSibling() else { break }
            switch sibling.tagName() {
                case "hr":
                    // We know the first hr comes after the end of the table
                    return nodeNames
                case "tr":
                    // This is the table entry with our information
                    let siblingChildren = sibling.children()

                    for tableEntry in siblingChildren {
                        let nodeEntries = tableEntry.children()
                        for entry in nodeEntries {
                            guard let name = try? entry.text() else { continue }
                            let href = try entry.attr("href")
                            if locations.contains(name) || nodeTypes.contains(name) {
                                continue
                            }
                            nodeNames[name] = href
                        }
                    }
                default:
                    break
            }
            element = sibling
        }
        return nodeNames
    }
}
