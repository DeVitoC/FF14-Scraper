//
//  MiningNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class FolkloreNodesScraper {
    let sectionNames = ["Botanist", "Miner", "Fisher"]
    let fileNames = ["Botany", "Mining", "Fishing"]

    func scrapeFolkloreNodesWiki() throws {
        let nodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Folklore_Nodes")!
        for (index, sectionName) in sectionNames.enumerated() {
            let nodes = try scrapeFolkloreNodes(url: nodesURL, section: sectionName)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try encoder.encode(nodes)
            let jsonString = String(decoding: json, as: UTF8.self)

            let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/\(fileNames[index])NodesFolklore.json")
            try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        }
    }

    private func scrapeFolkloreNodes(url: URL, section: String) throws -> [String: String] {
        let html = try String(contentsOf: url)
        let document = try SwiftSoup.parse(html)

        guard let sectionSpan = try document.select("#\(section)").first(),
              let h2 = sectionSpan.parent()
        else { print( "Unable to find table sections"); return [:] }

        var nodeNames: [String: String] = [:]

        var currentElement = h2
        mainLoop: while true {
            let sectionTag = currentElement.tagName()
            switch sectionTag {
                case "h2":
                    let currentSectionSpan = currentElement.children().first()
                    if try currentSectionSpan?.text() != "\(section)" {
                        break mainLoop
                    }
                case "table":
                    guard let tBody = currentElement.children().first()
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
                    break
            }

            guard let nextElement = try currentElement.nextElementSibling() else { break }
            currentElement = nextElement
        }

        return nodeNames
    }
}
