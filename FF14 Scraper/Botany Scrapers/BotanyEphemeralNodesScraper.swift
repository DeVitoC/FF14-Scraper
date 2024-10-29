//
//  BotanyNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class BotanyEphemeralNodesScraper {
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

        let botanySpans = try document.select("span[id^='Botanist']")

        var nodeNames: [String: String] = [:]

        for span in botanySpans {
            guard let botanyH3 = span.parent(),
                  let table = try botanyH3.nextElementSibling(),
                  let tBody = table.children().first()
            else { continue }

            for tr in tBody.children() {
                if tr.children().first()?.tagName() == "th" {
                    continue
                }

                let trChildren = tr.children()
                guard trChildren.count > 5 else { continue }
                let itemTD = trChildren[4]

                guard let itemsP = itemTD.children().first() else { continue }

                for element in itemsP.children() {
                    switch element.tagName() {
                        case "a":
                            let itemText = try element.text().trimmingCharacters(in: .whitespaces)
                            if itemText.isEmpty { continue }

                            let itemHref = try element.attr("href")
                            nodeNames[itemText] = itemHref
                        default:
                            continue
                    }
                }
            }
        }
        return nodeNames
    }
}
