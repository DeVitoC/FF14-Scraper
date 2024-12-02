//
//  CollectablesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/20/21.
//

import Foundation
import SwiftSoup

class CollectablesScraper {
    let bait = ["Caddisfly Larva", "Purse Web Spider", "Stonefly Nymph", "Balloon Bug", "Goblin Jig", "Bladed Steel Jig", "Brute Leech", "Blueclaw Shrimp", "Hedgemole Cricket", "Sweetfish", "Bullfrog"]
    let locations = locationStrings
    let sectionNames = ["Miner", "Botanist", "Fisher"]
    let fileNames = ["Mining", "Botany", "Fishing"]

    func scrapeCollectiblesWiki() throws {
        let collectiblesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Collectables/Gathered")!
        let html = try String(contentsOf: collectiblesURL)
        let document = try SwiftSoup.parse(html)

        for (index, sectionName) in sectionNames.enumerated() {
            let nodes = try scrapeCollectableNodes(section: sectionName, document: document)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try encoder.encode(nodes)
            let jsonString = String(decoding: json, as: UTF8.self)

            let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/\(fileNames[index])CollectiblesNormal.json")
            try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        }
    }

    private func scrapeCollectableNodes(section: String, document: Document) throws -> [String: String] {
        guard let sectionSpan = try document.select("#\(section)").first(),
              let sectionH3 = sectionSpan.parent(),
              var currentElement = try? sectionH3.nextElementSibling()
        else { return [:] }

        var nodeNames: [String: String] = [:]

        mainLoop: while true {
            let currentTag = currentElement.tagName()

            switch currentTag {
                case "h3":
                    break mainLoop
                case "table":
                    guard let tBody = currentElement.children().first() else { return [:] }

                    for tr in tBody.children() {
                        let nameTD: Element
                        if section == "Fisher" {
                            guard let tempTD = tr.children().first() else { continue }
                            nameTD = tempTD
                        } else {
                            guard let tempTD = try? tr.children().first()?.nextElementSibling() else { continue }
                            nameTD = tempTD
                        }

                        guard nameTD.tagName() != "th",
                              let name = try? nameTD.text().trimmingCharacters(in: .whitespaces),
                              let itemSpan = nameTD.children().first(),
                              let imageA = itemSpan.children().first(),
                              let itemA = try? imageA.nextElementSibling(),
                              let href = try? itemA.attr("href"),
                              !href.isEmpty,
                              !locations.contains(name),
                              !bait.contains(name)
                        else { continue }

                        let modifiedHref = href.replacingOccurrences(of: "https://ffxiv.consolegameswiki.com", with: "")
                        nodeNames[name] = modifiedHref
                    }
                default:
                    break
            }

            guard let nextElement = try? currentElement.nextElementSibling() else { break }
            currentElement = nextElement
        }

        return nodeNames
    }
}
