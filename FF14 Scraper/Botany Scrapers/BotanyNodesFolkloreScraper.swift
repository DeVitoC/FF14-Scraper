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
              let parserDiv = h2.parent()
        else { print( "Unable to find table sections"); return [:] }

        var nodeNames: [String: String] = [:]

        mainLoop: for section in parserDiv.children() {
            let sectionTag = section.tagName()

            switch sectionTag {
                case "h2", "hr":
                    if try section.text() != "Botanist" {
                        break mainLoop
                    }
                case "table":
                    guard let tBody = section.children().first()
                    else { continue }

                    for tr in tBody.children() {
                        if tr.children().first()?.tagName() == "th" {
                            continue
                        }

                        let trChildren = tr.children()
                        guard trChildren.count > 3 else { continue }
                        let itemTD = trChildren[2]
                        let itemText = try itemTD.text().trimmingCharacters(in: .whitespaces)

                        guard let span = itemTD.children().first(),
                              let a = try span.nextElementSibling()
                        else { continue }

                        let itemHref = try a.attr("href")
                        nodeNames[itemText] = itemHref
                    }
                default:
                    continue
            }
        }

        return nodeNames
    }
}
