//
//  EphemeralNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class EphemeralNodesScraper {
        let sections = ["Botanist", "Miner", "Fish"]
        let fileNames = ["Botany", "Mining", "Fishing"]

    func scrapeEphemeralNodesWiki() throws {
        let ephemeralNodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/Ephemeral_Nodes")!
        let html = try String(contentsOf: ephemeralNodesURL)
        let document = try SwiftSoup.parse(html)

        for (index, section) in sections.enumerated() {
            let ephemeralNodes = try scrapeEphemeralNodes(url: ephemeralNodesURL, section: section, document: document)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try encoder.encode(ephemeralNodes)
            let jsonString = String(decoding: json, as: UTF8.self)

            let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/Ephemeral\(fileNames[index])Nodes.json")
            try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        }
    }

    private func scrapeEphemeralNodes(url: URL, section: String, document: Document) throws -> [String: String] {
        let sectionSpans = try document.select("span[id^='\(section)']")

        print("\(section) sections: ", sectionSpans.count)
        var nodeNames: [String: String] = [:]

        for span in sectionSpans {
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

                if section == "Fish" {
                    guard let itemsP = try itemTD.children().first()?.nextElementSibling(),
                          let itemText = try? itemsP.text().trimmingCharacters(in: .whitespaces),
                          !itemText.isEmpty
                    else { continue }

                    let itemHref = try itemsP.attr("href")
                    nodeNames[itemText] = itemHref
                    continue
                }

                guard let itemsP = itemTD.children().first()
                else { continue }

                for element in itemsP.children() {
                    switch element.tagName() {
                        case "a":
                            let itemText = try element.text().trimmingCharacters(in: .whitespaces)
                            if itemText.isEmpty || itemText.contains("Cluster") || itemText.contains("Crystal") { continue }

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
