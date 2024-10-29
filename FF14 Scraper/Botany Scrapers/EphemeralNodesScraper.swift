//
//  BotanyNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class EphemeralNodesScraper {
    var nodes: [String: String] = [:]
    typealias BotanyNodeDictionary = [String: GatheringNode]
    let nodeTypes = ["Mature Tree", "Lush Vegetation Patch"]
    let locations = locationStrings
    
    func scrapeBotanyNodesWiki() throws {
        let botanistNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Ephemeral_Nodes")!
        let botanyNodes = try scrapeBotanyNodes(url: botanistNodesURL)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(botanyNodes)
        let jsonString = String(decoding: json, as: UTF8.self)
        
        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/NodesEphemeral.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeBotanyNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)
        
        guard let span = try document.select("#Shadowbringers").first(),
              let h2 = span.parent(),
              let topLevel = h2.parent() else { return [:] }
        let tables = topLevel.children().filter({ $0.tagName() == "table" })
        
        var nodeNames: [String: String] = [:]
        
        for table in tables {
            guard try table.previousElementSibling()?.children().first()?.text() != "Reduction Table" else { continue }
            guard let tbody = table.children().first() else { continue }
            for tr in tbody.children() {
                for tableItem in tr.children() {
                    if tableItem.tagName() == "th" {
                        continue
                    }
                    guard !tableItem.children().isEmpty() else { continue }
                    for div in tableItem.children() {
                        guard try div.previousElementSibling()?.tagName() == "div" else { continue }
                        guard let name = try? div.text() else { continue }
                        let href = try div.attr("href")
                        if locations.contains(name) || nodeTypes.contains(name) || name.contains("Aethersand") || name.contains("Crystal") {
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
