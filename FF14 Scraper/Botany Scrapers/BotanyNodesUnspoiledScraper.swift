//
//  BotanyNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class BotanyNodeUnspoiledScraper {
    var nodes: [String: String] = [:]
    typealias BotanyNodeDictionary = [String: GatheringNode]
    let nodeTypes = ["Mature Tree", "Lush Vegetation Patch"]
    let locations = locationStrings
    
    func scrapeBotanyNodesWiki() throws {
        let botanistNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Unspoiled_Botanist_Nodes")!
        let botanyNodes = try scrapeBotanyNodes(url: botanistNodesURL)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(botanyNodes)
        let jsonString = String(decoding: json, as: UTF8.self)
        
        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/botanyNodesUnspoiled.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeBotanyNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)
                
        guard let span = try document.select("#Shadowbringers").first(),
                let h2 = span.parent(),
                let topLevel = h2.parent() else { return [:] }
        let tables = topLevel.children()

        var nodeNames: [String: String] = [:]

        for item in tables {
            if item.tagName() == "hr" {
                break
            } else if item.tagName() == "p" || item.tagName() == "dl" || item.tagName() == "div" || item.tagName() == "h2" {
                continue
            } else if item.tagName() == "table" {
                guard let tbody = item.children().first() else { continue }
                for tr in tbody.children() { // "tr"'s
                    for tableItem in tr.children() {
                        if tableItem.tagName() == "th" {
                            continue
                        }
                        guard let div = tableItem.children().first(), let a = try div.nextElementSibling() else { continue }
                        guard let name = try? a.text() else { continue }
                        let href = try a.attr("href")
                        if locations.contains(name) || nodeTypes.contains(name) {
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
