//
//  NormalNodesScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

class NormalNodesScraper {
    let nodeTypes = ["Mature Tree", "Lush Vegetation Patch", "Rocky Outcrop", "Mineral Deposit"]
    let locations = locationStrings
    let sectionNames = ["Botanist", "Miner"]
    let fileNames = ["Botany", "Mining"]

    func scrapeNormalNodesWiki() throws {
        for (index, sectionName) in sectionNames.enumerated() {
            let nodesURL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/\(sectionName)_Node_Locations")!
            let html = try String(contentsOf: nodesURL)
            let document = try SwiftSoup.parse(html)

            let nodes = try scrapeNormalNodes(document: document, section: sectionName)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try encoder.encode(nodes)
            let jsonString = String(decoding: json, as: UTF8.self)

            let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/\(fileNames[index])NodesNormal.json")
            try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        }
    }

    private func scrapeNormalNodes(document: Document, section: String) throws -> [String: String] {
        guard var element = getTableRow(document: document, section: section) else {
            print("Unable to get main element")
            return [:]
        }

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
                        let nodeEntries = tableEntry.children()
                        for entry in nodeEntries {
                            guard let name = try? entry.text() else { continue }
                            let href = try entry.attr("href")
                            if locations.contains(name) || nodeTypes.contains(name) || name.isEmpty || href.isEmpty {
                                continue
                            }
                            nodeNames[name] = href
                        }
                    }
                default:
                    break
            }
            element = sibling
        }
        return nodeNames
    }

    private func getTableRow(document: Document, section: String) -> Element? {
        do {
            guard let div = try document.select("#mw-content-text").first(),
                  let parserDiv = div.children().first(),
                  let secondParserChild = try parserDiv.children().first()?.nextElementSibling()
            else {
                print("Unable to get main divs")
                return nil
            }

            let table: Element
            if section == "Botanist" {
                table = secondParserChild
            } else {
                guard let miningTable = try secondParserChild.nextElementSibling()
                else { return nil }
                table = miningTable
            }

            guard let tBody = table.children().first(),
                  let tableRow = tBody.children().first()
            else { return nil }

            return tableRow
        } catch {
            print("Error getting table row: ", error)
            return nil
        }
    }
}
