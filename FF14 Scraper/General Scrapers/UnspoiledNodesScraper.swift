//
//  UnspoiledNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class UnspoiledNodesScraper {
    let nodeTypes = ["Mature Tree", "Lush Vegetation Patch", "Rocky Outcrop", "Mineral Deposit"]
    let locations = locationStrings
    let sections = ["Botanist", "Miner"]
    let fileNames = ["Botany", "Mining"]


    func scrapeUnspoiledNodesWiki() throws {
        let unspoiledNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Unspoiled_Nodes")!
        let html = try String(contentsOf: unspoiledNodesURL)
        let document = try SwiftSoup.parse(html)

        for (index, section) in sections.enumerated() {
            let unspoiledNodes = try scrapeUnspoiledNodes(url: unspoiledNodesURL, section: section, document: document)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try encoder.encode(unspoiledNodes)
            let jsonString = String(decoding: json, as: UTF8.self)

            let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/\(fileNames[index])NodesUnspoiled.json")
            try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        }
    }

    private func scrapeUnspoiledNodes(url: URL, section: String, document: Document) throws -> [String: String] {
        guard let span = try document.select("#\(section)").first(),
              let h2 = span.parent()
        else { return [:] }

        var nodeNames: [String: String] = [:]

        var currentElement = h2
        mainLoop: while true {
            let currentTag = currentElement.tagName()
            switch currentTag {
                case "h2":
                    let itemText = try currentElement.text().trimmingCharacters(in: .whitespaces)
                    print("itemText: ", itemText)
                    if itemText != section {
                        break mainLoop
                    }
                case "table":
                    guard let tbody = currentElement.children().first() else { continue }
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
                default:
                    break
            }

            guard let nextElement = try? currentElement.nextElementSibling()
            else { break }
            currentElement = nextElement
        }

        return nodeNames
    }
}
