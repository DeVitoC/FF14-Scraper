//
//  BotanyNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class BotanyNodesScraper {
    var nodes: [String: String] = [:]
    typealias BotanyNodeDictionary = [String: GatheringNode]
    let nodeTypes = ["Mature Tree", "Lush Vegetation Patch"]
    let locations = locationStrings

    func scrapeBotanyNodesWiki() throws {
        let botanistNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Botanist_Node_Locations")!
        let botanyNodes = try scrapeBotanyNodes(url: botanistNodesURL)
        print(botanyNodes)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(botanyNodes)
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/botanyNodesNormal.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }

    private func scrapeBotanyNodes(url: URL) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)


        guard let div = try document.select("#mw-content-text").first(),
                let divChild = div.children().first(),
                let divGrandchild = try divChild.children().first()?.nextElementSibling(),
                let divGGrandchild = divGrandchild.children().first(),
                let divGGGrandchild = divGGrandchild.children().first() else { return [:] }
        
        var element = divGGGrandchild

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
                    print()
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
                print(sibling)
            }
            element = sibling
        }
        return nodeNames
    }
}
