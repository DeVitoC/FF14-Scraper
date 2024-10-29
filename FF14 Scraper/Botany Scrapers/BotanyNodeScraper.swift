//
//  GatheringNodeScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/21/21.
//

import Foundation
import SwiftSoup

class BotanyNodeScraper {
    private var nodesToSearch: [String: String] = [:]
    private var nodes: [GatheringNode] = []
    private var missedNodes: [String] = []
    private typealias GatheringNodeDictionary = [String: GatheringNode]
    private let locations = locationStrings
    private let type = ["Submersible Components", "Bone", "Cloth", "Dye", "Ingredient", "Leather", "Lumber", "Metal", "Part", "Reagent", "Seafood", "Stone"]

    func scrapeGatheringNodesWiki() throws {
        guard let gamerEscapeWikiURL = URL(string: "https://ffxiv.consolegameswiki.com")
        else { return }
//        try scrapeGatheringNodes(consoleGamerUrl: gamerEscapeWikiURL)
                let fm = FileManager.default
                lazy var path: URL = {
                    fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
                }()
                let filenames = ["botanyNodesNormal.json", "botanyNodesUnspoiled.json", "botanyNodesFolklore.json"]

                for filename in filenames {
                    let jsonDecoder = JSONDecoder()
        
                    // Get JSON
                    guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent(filename).path) else { return }
        
                    // decode JSON
                    do {
                        let data = Data(jsonData)
                        let itemNames = try jsonDecoder.decode([String: String].self, from: data)
                        for (_, address) in itemNames {
                            try scrapeGatheringNodes(consoleGamerUrl: gamerEscapeWikiURL, testItem: address)
                            let seconds = 2.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {}
                        }
                    } catch let error {
                        NSLog("\(error)")
                    }
                }

                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let json = try encoder.encode(nodes)
                let jsonString = String(decoding: json, as: UTF8.self)
        
                let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/AllBotanyNodes.json")
                try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
        
                let missedNodesJson = try encoder.encode(missedNodes)
                let missedNodesJsonString = String(decoding: missedNodesJson, as: UTF8.self)
                let missedNodesFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/MissedNodesBotany.json")
                try missedNodesJsonString.write(to: missedNodesFile, atomically: true, encoding: String.Encoding.utf8)
    }

    private func scrapeGatheringNodes(consoleGamerUrl: URL, testItem: String = "/wiki/Dated_Radz-at-Han_Coin") throws {
        // scrape GamerEscape wiki
        let gamerEscapeWikiItemURL = consoleGamerUrl.appendingPathComponent(testItem)
        let gamerEscapeHTML = try String(contentsOf: gamerEscapeWikiItemURL)
        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)

        // Get main content and the top table/info panel
        guard let contentTextDiv = try gamerEscapeDocument.select("#mw-content-text").first(),
              let parserDiv = contentTextDiv.children().first(),
              let infoBoxDiv = parserDiv.children().first(),
              let iconSpanDiv = try infoBoxDiv.children().first()?.nextElementSibling(),
              let nameP = try iconSpanDiv.nextElementSibling()
        else {
            print("unable to get element in lines 70 - 74: main content and top info panel")
            missedNodes.append(testItem)
            return
        }

        // MARK: Get Name
        let itemName = try nameP.text()

        // MARK: Get Image URL
        guard let imageSpan = iconSpanDiv.children().first(),
              let imageA = imageSpan.children().first()
        else {
            print("unable to get elements in lines 85 - 86")
            missedNodes.append(testItem)
            return
        }

        let itemImgUrl = try imageA.attr("href")

        // MARK: Get Type and Expac
        guard let tradeableDiv = try nameP.nextElementSibling(),
              let descriptionDiv = try tradeableDiv.nextElementSibling(),
              let descriptionList = descriptionDiv.children().first()
        else {
            print("unable to get elements in lines 96 - 98")
            missedNodes.append(testItem)
            return
        }

        var itemType: String = ""
        var itemExpac: Int = 0

        for child in descriptionList.children() {
            guard child.tagName() == "dt" else { continue }

            guard let aElement = child.children().first(),
                  let nextElement = try child.nextElementSibling()
            else { continue }
            let aTitle = try aElement.attr("title")

            switch aTitle {
                case "Item":
                    itemType = try nextElement.text()
                case "Patches":
                    guard let nextElementChild = nextElement.children().first() else { continue }
                    var patchText = try nextElementChild.text()
                    patchText = patchText.replacingOccurrences(of: "a", with: "").replacingOccurrences(of: "b", with: "")
                    guard let patchNumber = Float(patchText)
                    else {
                        print("Failed to convert patch number on line 123")
                        missedNodes.append(testItem)
                        return
                    }
                    itemExpac = Int(patchNumber - 2)
                default:
                    continue
            }
        }

        // MARK: Get Description
        guard let blockQuote = try infoBoxDiv.nextElementSibling(),
              let descriptionDiv = try blockQuote.children().first()?.nextElementSibling(),
              let desctiptionP = descriptionDiv.children().first()
        else {
            print("unable to get elements in lines 136 - 138")
            missedNodes.append(testItem)
            return
        }
        let itemDescription = try desctiptionP.text()


        // MARK: Get Table information
        guard let aquisitionH2 = try blockQuote.nextElementSibling(),
              let gatheringH3 = try aquisitionH2.nextElementSibling(),
              let table = try gatheringH3.nextElementSibling()
        else {
            print("unable to get elements in lines 148 - 150")
            missedNodes.append(testItem)
            return
        }

        var tableBody: Element
        if let tableFirst = table.children().first(),
           let tableSecondTag = try? tableFirst.nextElementSibling(),
           tableFirst.tagName() == "thead",
           tableSecondTag.tagName() == "tbody" {
            tableBody = try table.children().first()!.nextElementSibling()!
        } else if table.children().first()?.tagName() == "tbody" {
            tableBody = table.children().first()!
        } else {
            print("unable to get table in lines 158 - 164")
            missedNodes.append(testItem)
            return
        }

        var itemLvl: Int?
        var itemLocationInfo: [NodeLocationInfo] = []
        for row in tableBody.children() {
            // Ignore the header row and get "a" tag for first item of first row
            guard let column1Test = row.children().first(),
                  let column1Div1Test = column1Test.children().first(),
                  let column1A1Test = column1Div1Test.children().first()
            else { continue }

            // Check if row is for Botany, otherwise continue to next row
            let a1TitleTest = try column1A1Test.attr("title")
            if !a1TitleTest.contains("Botanist") {continue}

            var stars: Int = 0
            var itemLocation: String = ""
            var times: [Int] = []
            var x: Int = 0
            var y: Int = 0

            // If row is a Botany row, get information
            for (index, column) in row.children().enumerated() {
                if column.tagName() == "th" {continue}
                switch index {
                    case 0:
                        let columnText = try column.text()
                        let columnParts = columnText.split(separator: " ")
                        for part in columnParts {
                            // MARK: Get Item lvl
                            if let itemLvlPart = Int(part) {
                                itemLvl = itemLvlPart
                            // MARK: Get stars
                            } else if part.contains("★") {
                                stars = part.count
                            }
                        }
                    case 1:
                        // MARK: Get Location
                        guard let columnA1 = column.children().first(),
                              let columnA2 = try columnA1.nextElementSibling()
                        else {
                            print("unable to get elements at lines 208 - 209")
                            missedNodes.append(testItem)
                            return
                        }
                        let locationText = try columnA2.text()
                        itemLocation = locationText.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")

                    case 2:
                        // level req
                        continue
                    case 3:
                        // perception
                        continue
                    case 4:
                        // MARK: Get Time
                        let columnText = try column.text()
                        let columnParts = columnText.split(separator: "/")
                        for part in columnParts {
                            let partNumber = part.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "")
                            if partNumber.isEmpty && !times.isEmpty {
                                times.append(times[0] + 12)
                            }
                            if let partInt = Int(partNumber) {
                                times.append(part.contains("AM") ? partInt : partInt + 12)
                            }
                        }

                    case 5:
                        // MARK: Get Coords
                        let coords = try column.text()
                            .replacingOccurrences(of: "(", with: "")
                            .replacingOccurrences(of: ")", with: "")
                            .replacingOccurrences(of: "X", with: "")
                            .replacingOccurrences(of: "Y", with: "")
                            .replacingOccurrences(of: ":", with: "")
                            .replacingOccurrences(of: " ", with: "")


                        let coordParts = coords.split(separator: ",")
                        let xString = String(coordParts[0])
                        let xFloat = Float(xString) ?? 0.0
                        x = Int(xFloat)
                        let yString = String(coordParts[1])
                        let yFloat = Float(yString) ?? 0.0
                        y = Int(yFloat)
                    default:
                        print("hit invalid table column on line 191")
                        missedNodes.append(testItem)
                        return
                }
            }

            if !times.isEmpty {
                for time in times {
                    let locationInfo = NodeLocationInfo(time: time, location: itemLocation, stars: stars, x: x, y: y)
                    itemLocationInfo.append(locationInfo)
                }
            } else {
                let locationInfo = NodeLocationInfo(time: nil, location: itemLocation, stars: stars, x: x, y: y)
                itemLocationInfo.append(locationInfo)
            }
        }

        // Verify itemLvl is not nil. Otherwise count this as a missed node
        guard let itemLvl else {
            print("itemLvl is nil in line 275")
            missedNodes.append(testItem)
            return
        }

        for itemLocation in itemLocationInfo {
            let gatheringItem = GatheringNode(
                name: itemName,
                time: itemLocation.time,
                location: itemLocation.location,
                img: itemImgUrl,
                description: itemDescription,
                type: itemType,
                lvl: itemLvl,
                stars: itemLocation.stars,
                x: itemLocation.x,
                y: itemLocation.y,
                expac: itemExpac
            )
            nodes.append(gatheringItem)
        }

        print(nodes)
    }
}
