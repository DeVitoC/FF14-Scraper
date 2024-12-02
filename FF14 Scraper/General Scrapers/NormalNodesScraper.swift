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
    let bait = ["Pill Bug", "Lugworm", "Bloodworm", "Crayfish Ball", "Butterworm", "Crow Fly", "Rat Tail", "Midge Basket", "Spinnerbait", "Crab Ball", "Floating Minnow", "Spoon Worm", "Sinking Minnow", "Goby Ball", "Northern Krill", "Yumizuno", "Glowworm", "Krill Cage Feeder", "Steel Jig", "Heavy Steel Jig", "Bass Ball", "Moth Pupa", "Brass Spoon Lure", "Saltwater Boilie", "Mythril Spoon Lure", "Syrphid Basket", "Freshwater Boilie", "Sand Gecko", "Sand Leech", "Chocobo Fly", "Stem Borer", "Topwater Frog", "Hoverworm"]
    let locations = locationStrings
    let sectionNames = ["Botanist", "Miner", "Fishing"]
    let fileNames = ["Botany", "Mining", "Fishing"]

    func scrapeNormalNodesWiki() throws {
        for (index, sectionName) in sectionNames.enumerated() {
            let nodesURL: URL = URL(string: "https://ffxiv.consolegameswiki.com/wiki/\(sectionName)\(sectionName == "Fishing" ? "" : "_Node")_Locations")!
            let html = try String(contentsOf: nodesURL)
            let document = try SwiftSoup.parse(html)

            let nodes = sectionName == "Fishing" ? try scrapeNormalFishingNodes(document: document) : try scrapeNormalGatheringNodes(document: document, section: sectionName)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let json = try encoder.encode(nodes)
            let jsonString = String(decoding: json, as: UTF8.self)

            let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/\(fileNames[index])NodesNormal.json")
            try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        }
    }

    private func scrapeNormalGatheringNodes(document: Document, section: String) throws -> [String: String] {
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

    private func scrapeNormalFishingNodes(document: Document) throws -> [String: String] {
        guard let element = getTableRow(document: document, section: "Fishing") else { return [:] }
        let tables = element.children()

        var nodeNames: [String: String] = [:]

        for child in tables where child.tagName() == "table" {
            guard let tbody = child.children().first() else { return [:] }
            for tr in tbody.children() {
                for td in tr.children() where td.tagName() != "th" {
                    for tableEntry in td.children() {
                        guard let name = try? tableEntry.text() else { continue }
                        let href = try tableEntry.attr("href")
                        guard !href.isEmpty else { continue }
                        if locations.contains(name) || bait.contains(name) || name.isEmpty || href.isEmpty {
                            continue
                        }
                        nodeNames[name] = href
                    }
                }
            }
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
            } else if section == "Miner" {
                guard let miningTable = try secondParserChild.nextElementSibling()
                else { return nil }
                table = miningTable
            } else {
                return parserDiv
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
