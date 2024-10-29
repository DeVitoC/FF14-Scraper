//
//  BotanyNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class BotanyNodeFolkloreScraper {
    var nodes: [String: String] = [:]
    typealias BotanyNodeDictionary = [String: GatheringNode]
    let nodeTypes = ["Mature Tree", "Lush Vegetation Patch"]
    let locations = locationStrings

    func scrapeBotanyNodesWiki() throws {
        let botanistNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Folklore_Nodes")!
        let botanyNodes = try scrapeBotanyNodes(url: botanistNodesURL)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(botanyNodes)
        let jsonString = String(decoding: json, as: UTF8.self)
        
        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/botanyNodesFolklore.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    
    private func scrapeBotanyNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)

        guard let span = try document.select("#Botanist").first(),
              let h2 = span.parent(),
              let table = try h2.nextElementSibling(),
              let tbody = table.children().first() else { print( "no span found"); return [:] }
        
        var element = tbody

        var nodeNames: [String: String] = [:]

        for sibling in element.children() {
//            guard let sibling = try element.nextElementSibling() else { break }
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