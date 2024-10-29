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
        let testing = true
        if testing {
            guard let item = "/wiki/Rarefied_Windsbalm_Bay_Leaf".removingPercentEncoding else { print("failed to format item"); return }
            try scrapeGatheringNodes(consoleGamerUrl: gamerEscapeWikiURL, item: item)
        } else {
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
                        guard let item = address.removingPercentEncoding else {
                            print("failed to format item")
                            missedNodes.append(address)
                            return
                        }
                        try scrapeGatheringNodes(consoleGamerUrl: gamerEscapeWikiURL, item: item)
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
    }

    private func scrapeGatheringNodes(consoleGamerUrl: URL, item: String) throws {
        // scrape GamerEscape wiki
        let gamerEscapeWikiItemURL = consoleGamerUrl.appendingPathComponent(item)
        let gamerEscapeHTML = try String(contentsOf: gamerEscapeWikiItemURL)
        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)

        // Get main content and the top table/info panel
        guard let contentTextDiv = try gamerEscapeDocument.select("#mw-content-text").first(),
              let parserDiv = contentTextDiv.children().first(),
              var infoBoxDiv = parserDiv.children().first()
        else {
            print("unable to get elements lines 74-76")
            missedNodes.append(item)
            return
        }
        if infoBoxDiv.tagName() != "div" {
            infoBoxDiv = try infoBoxDiv.nextElementSibling()!
        }

        guard let iconSpanDiv = try infoBoxDiv.children().first()?.nextElementSibling(),
              let nameP = try iconSpanDiv.nextElementSibling()
        else {
            print("unable to get element in lines 86 - 87: main content and top info panel")
            missedNodes.append(item)
            return
        }

        // MARK: Get Name
        let itemName = try nameP.text()

        // MARK: Get Image URL
        guard let imageSpan = iconSpanDiv.children().first(),
              let imageA = imageSpan.children().first()
        else {
            print("unable to get elements in lines 85 - 86")
            missedNodes.append(item)
            return
        }

        let itemImgUrl = try imageA.attr("href")

        // MARK: Get Type and Expac
        guard let tradeableDiv = try nameP.nextElementSibling(),
              let descriptionDiv = try tradeableDiv.nextElementSibling(),
              let descriptionList = descriptionDiv.children().first()
        else {
            print("unable to get elements in lines 96 - 98")
            missedNodes.append(item)
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
                        missedNodes.append(item)
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
            missedNodes.append(item)
            return
        }
        let itemDescription = try desctiptionP.text()


        // MARK: Get Table information
        guard let aquisitionH2 = try blockQuote.nextElementSibling(),
              let gatheringH3 = try aquisitionH2.nextElementSibling(),
              let table = try gatheringH3.nextElementSibling()
        else {
            print("unable to get elements in lines 148 - 150")
            missedNodes.append(item)
            return
        }
        var element: Element = table

        var itemLvl: Int?
        var itemLocationInfo: [NodeLocationInfo] = []

        if element.tagName() == "h3", try element.nextElementSibling()?.tagName() == "table" {
            element = try element.nextElementSibling()!
        }
        print(element)

        switch element.tagName() {
            case "table":
                if let previousElement = try element.previousElementSibling(), let nextElement = try element.nextElementSibling() {
                    let previousText = try previousElement.text()
                    let nextText = try nextElement.text()
                    if previousText != "Gathering", nextText == "Gathering", let nextTable = try nextElement.nextElementSibling() {
                        element = nextTable
                    }
                }
                var tableBody: Element
                if let tableFirst = element.children().first(),
                   let tableSecondTag = try? tableFirst.nextElementSibling(),
                   tableFirst.tagName() == "thead",
                   tableSecondTag.tagName() == "tbody" {
                    tableBody = try element.children().first()!.nextElementSibling()!
                } else if element.children().first()?.tagName() == "tbody" {
                    tableBody = element.children().first()!
                } else {
                    print("unable to get table in lines 158 - 164")
                    missedNodes.append(item)
                    return
                }

                var foundBotanistRow = false
                rowLoop: for row in tableBody.children() {
                    // Ignore the header row and get "a" tag for first item of first row
                    guard let column1Test = row.children().first(),
                          let column1Div1Test = column1Test.children().first(),
                          let column1A1Test = column1Div1Test.children().first()
                    else { continue }

                    // Check if row is for Botany, otherwise continue to next row
                    let a1TitleTest = try column1A1Test.attr("title")
                    if !a1TitleTest.contains("Botanist") {continue}
                    foundBotanistRow = true

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
                                    missedNodes.append(item)
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
                                guard coordParts.count >= 2 else {
                                    continue rowLoop
                                }
                                let xString = String(coordParts[0])
                                let xFloat = Float(xString) ?? 0.0
                                x = Int(xFloat)
                                let yString = String(coordParts[1])
                                let yFloat = Float(yString) ?? 0.0
                                y = Int(yFloat)
                            default:
                                print("hit invalid table column on line 191")
                                missedNodes.append(item)
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

                if foundBotanistRow == false {
                    print("no valid bonanist info")
                    return
                }
                if itemLocationInfo.isEmpty {
                    print("no valid locations: line 286")
                    missedNodes.append(item)
                    return
                }
            case "p", "div", "ul", "h3", "dl":
                switch element.tagName() {
                    case "p":
                        element = table
                    case "div", "h3":
                        guard let p = try element.nextElementSibling()
                        else {
                            print("unable to get elements in lines 298")
                            missedNodes.append(item)
                            return
                        }
                        element = p
                    case "ul", "dl":
                        guard let li = element.children().first() else {
                            print("unable to get elements in lines 318")
                            missedNodes.append(item)
                            return
                        }
                        element = li
                    default:
                        print("table is not a handled element line 294")
                        missedNodes.append(item)
                        return
                }

                let processedInfo = try processStringTable(element: element, item: item)
                guard let locationInfo = processedInfo.0 else {
                    return
                }
                itemLvl = processedInfo.1

                itemLocationInfo.append(locationInfo)
            case "h4":
                guard try element.text() == "Botany",
                      let ul = try element.nextElementSibling()
                else {
                    print("unable to find element in line 385")
                    missedNodes.append(item)
                    return
                }
                element = ul

                for li in ul.children() {
                    let procesedInfo = try processStringTable(element: li, item: item)
                    guard let locationInfo = procesedInfo.0 else {
                        return
                    }
                    itemLvl = procesedInfo.1

                    itemLocationInfo.append(locationInfo)
                }
            default:
                print("table is not a valid element line 150 \(element.tagName())")
                missedNodes.append(item)
                return
        }


        // Verify itemLvl is not nil. Otherwise count this as a missed node
        guard let itemLvl else {
            print("itemLvl is nil in line 280")
            missedNodes.append(item)
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
    }

    func processStringTable(element: Element, item: String) throws -> (NodeLocationInfo?, Int) {
        var stars: Int = 0
        var itemLocation: String = ""
        var x: Int = 0
        var y: Int = 0
        var itemLvl: Int = 0

        let itemText: String = try element.text()
        let itemTextParts = itemText.split(separator: " ")
        guard itemTextParts.count > 1 else {
            print("item text is not valid line 292")
            missedNodes.append(item)
            return (nil, itemLvl)
        }

        // MARK: Set Item lvl
        let itemLvlString = itemTextParts[1].replacingOccurrences(of: "★", with: "")
        if let itemLvlInt = Int(itemLvlString) {
            itemLvl = itemLvlInt
        } else {
            print("item level is not valid line 290")
            missedNodes.append(item)
            return (nil, itemLvl)
        }

        // MARK: Set Stars
        let starsString = itemTextParts[1].trimmingCharacters(in: .alphanumerics)
        stars = starsString.count

        // MARK: SetLocation
        var locationElement: Element? = nil
        if element.children().count >= 3 {
            guard let a1 = element.children().first(),
                  let a2 = try a1.nextElementSibling(),
                  let a3 = try a2.nextElementSibling()

            else {
                print("unable to get elements in lines 324 - 326")
                missedNodes.append(item)
                return (nil, itemLvl)
            }
            locationElement = a3

            // MARK: Set coordinates
            let xString = itemTextParts[itemTextParts.count - 2]
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: "X", with: "")
                .replacingOccurrences(of: ":", with: "")
            x = Int(Float(xString) ?? 0.0)

            let yString = itemTextParts[itemTextParts.count - 1]
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "Y", with: "")
                .replacingOccurrences(of: ":", with: "")
            y = Int(Float(yString) ?? 0.0)
        } else if element.children().count == 2 {
            guard let a1 = element.children().first(),
                  let a2 = try a1.nextElementSibling()
            else {
                print("unable to get elements in lines 324 - 326")
                missedNodes.append(item)
                return (nil, itemLvl)
            }
            locationElement = a2

            // MARK: Set coordinates
            let coordString = itemTextParts[itemTextParts.count - 1]
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: "x", with: "")
                .replacingOccurrences(of: ")", with: "")
                .replacingOccurrences(of: "y", with: "")
                .replacingOccurrences(of: ".", with: "")
            let coordParts = coordString.split(separator: ",")

            if coordParts.count == 2 {
                let xString = coordParts[0]
                x = Int(Float(xString) ?? 0.0)

                let yString = coordParts[1]
                y = Int(Float(yString) ?? 0.0)
            }
        }

        let locationText = try locationElement?.text()
        guard let locationText, !locationText.isEmpty else {
            print("location text is empty in line 332")
            missedNodes.append(item)
            return (nil, itemLvl)
        }
        itemLocation = locationText

        let locationInfo = NodeLocationInfo(time: nil, location: itemLocation, stars: stars, x: x, y: y)

        return (locationInfo, itemLvl)
    }
}
