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
    private let locations = ["Limsa Lominsa Upper Decks", "Limsa Lominsa Lower Decks", "Eastern La Noscea", "Lower La Noscea", "Middle La Noscea", "Upper La Noscea", "Western La Noscea", "Outer La Noscea", "New Gridania", "Old Gridania", "Central Shroud", "East Shroud", "North Shroud", "South Shroud", "Central Thanalan", "Eastern Thanalan", "Northern Thanalan", "Southern Thanalan", "Western Thanalan", "The Lavender Beds", "Coerthas Central Highlands", "Coerthas Western Highlands", "Mor Dhona", "Mists", "Labender Beds", "The Dravanian Forelands", "The Dravanian Hinterlands", "The Churning Mists", "The Sea of Clouds", "The Fringes", "The Peaks", "The Ruby Sea", "The Azim Steppe", "Yanxia", "The Lochs", "Amh Araeng", "Lakeland", "Kholusia", "Il Mheg", "The Rak'tika Greatwood", "Labyrinthos", "Thavnair", "Garlemald", "Azys Lla", "The Tempest", "Rhalgr's Reach"]
    private let type = ["Submersible Components", "Bone", "Cloth", "Dye", "Ingredient", "Leather", "Lumber", "Metal", "Part", "Reagent", "Seafood", "Stone"]
    
    func scrapeGatheringNodesWiki() throws {
        guard let gamerEscapeWikiURL = URL(string: "https://ffxiv.gamerescape.com")
        else { return }
        try scrapeGatheringNodes(gamerEscapeURL: gamerEscapeWikiURL)
//        let fm = FileManager.default
//        lazy var path: URL = {
//            fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
//        }()
//        let filenames = ["botanyNodesNormal.json", "botanyNodesUnspoiled.json", "botanyNodesFolklore.json"]
//
//        for filename in filenames {
//            let jsonDecoder = JSONDecoder()
//
//            // Get JSON
//            guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent(filename).path) else { return }
//
//            // decode JSON
//            do {
//                let data = Data(jsonData)
//                let itemNames = try jsonDecoder.decode([String: String].self, from: data)
//                for (_, address) in itemNames {
//                    try scrapeGatheringNodes(gamerEscapeURL: gamerEscapeWikiURL, testItem: address)
//                    let seconds = 2.0
//                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {}
//                }
//            } catch let error {
//                NSLog("\(error)")
//            }
//        }
//
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        let json = try encoder.encode(nodes)
//        let jsonString = String(decoding: json, as: UTF8.self)
//
//        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/AllBotanyNodes.json")
//        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
//
//        let missedNodesJson = try encoder.encode(missedNodes)
//        let missedNodesJsonString = String(decoding: missedNodesJson, as: UTF8.self)
//        let missedNodesFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/MissedNodesBotany.json")
//        try missedNodesJsonString.write(to: missedNodesFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeGatheringNodes(gamerEscapeURL: URL, testItem: String = "/wiki/Dated_Radz-at-Han_Coin") throws {
        // scrape GamerEscape wiki
        let gamerEscapeWikiItemURL = gamerEscapeURL.appendingPathComponent(testItem)
        let gamerEscapeHTML = try String(contentsOf: gamerEscapeWikiItemURL)
        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)

        // Get main content and the top table/info panel
        guard let contentTextDiv = try gamerEscapeDocument.select("#mw-content-text").first(),
              let contentParentDiv = contentTextDiv.parent(),
              let nameH1 = contentParentDiv.children().first(),
              let contentTextDivChild = contentTextDiv.children().first(),
              let topInfoTable = contentTextDivChild.children().first(),
              let topInfoTbody = topInfoTable.children().first()
        else {
            print("unable to get element in lines 69 - 74: main content and top info panel")
            missedNodes.append(testItem)
            return
        }

        // MARK: Get Name
        let itemName = try nameH1.text()

        // Get name bar left elements
        guard let nameBarTR = topInfoTbody.children().first(),
              let nameBarLeftTD = nameBarTR.children().first(),
              let nameBarLeftTable = nameBarLeftTD.children().first(),
              let nameBarLeftTbody = nameBarLeftTable.children().first(),
              let nameBarLeftTR = nameBarLeftTbody.children().first(),
              let imageTD = nameBarLeftTR.children().first(),
              let imageA = imageTD.children().first(),
              let nameAndTypeTD = try imageTD.nextElementSibling(),
              let typeDiv = nameAndTypeTD.children().last()
        else {
            print("unable to get elements in lines 85 - 93")
            missedNodes.append(testItem)
            return
        }

        // MARK: Get Image URL
        let itemImgUrl = try imageA.attr("href")

        // MARK: Get Type
        let itemType = try typeDiv.text()

        // Get name bar right elements
        guard let expacTD = try nameBarLeftTD.nextElementSibling(),
              let itemA = expacTD.children().first(),
              let expacNumberDiv = try itemA.nextElementSibling()?.nextElementSibling()
        else {
            print("unable to get elements in lines 107 - 109")
            missedNodes.append(testItem)
            return
        }

        // MARK: Get Expac
        var patchText = try expacNumberDiv.text().components(separatedBy: " ")[1]
        patchText
        guard let patchNumber = Float(patchText)
        else {
            print("Failed to convert patch number on line 118")
            missedNodes.append(testItem)
            return
        }
        let itemExpac = Int(patchNumber - 2)

        // Get Info Panel Bottom
        guard let infoPanelBottomTR = try nameBarTR.nextElementSibling()?.nextElementSibling(),
              let infoPanelBottomTBody = infoPanelBottomTR.children().first()?.children().first()?.children().first()
        else {
            print("unable to get element in lines 127 - 128")
            missedNodes.append(testItem)
            return
        }

        // MARK: Get Description
        let descriptionHeaderTR = try infoPanelBottomTBody.children().filter({ try $0.text().contains("Description:") })
        guard let descriptionTR = try descriptionHeaderTR.first?.nextElementSibling()
        else {
            print("unable to get elements in line 137")
            missedNodes.append(testItem)
            return
        }
        let itemDescription = try descriptionTR.text()

        // MARK: Get Item lvl
        var itemLvl: Int = 0
        for tr in infoPanelBottomTBody.children() {
            guard let td1 = tr.children().first(),
                  try td1.text().contains("Item Level"),
                  let td2 = try td1.nextElementSibling(),
                  let td2Text = Int(try td2.text())
            else {
                continue
            }
            itemLvl = td2Text
        }

        // Get gathering location elements
        var itemLocationInfo: [NodeLocationInfo] = []
        for gatheringSource in ["Logging", "Harvesting"] {
            // Get section for specific gathering source
            guard let gatheringSourceSpan = try gamerEscapeDocument.select("#\(gatheringSource)").first()
            else {
                print("line 162: \(itemName)");
                continue
            }

            // MARK: Get Gathering Source
            let itemSource = gatheringSource

            // Get Element Table element for gathering Source
            guard let gatheringSourceParentDiv = gatheringSourceSpan.parent(),
                  let gatheringSourceParentTH = gatheringSourceParentDiv.parent(),
                  let gatheringSourceParentTR = gatheringSourceParentTH.parent(),
                  let gatheringSourceTable = try gatheringSourceParentTR.nextElementSibling()?.children().first()?.children().first(),
                  let gatheringSourceTBody = gatheringSourceTable.children().first()
            else {
                print("unable to get element in lines 172 - 176")
                missedNodes.append(testItem)
                return
            }

            // get location information
            for tr in gatheringSourceTBody.children() {
                guard let nodeSlotTD = tr.children().first(), // to get location and coords
                      let nodeReqTD = try nodeSlotTD.nextElementSibling(), // to get time
                      let gatheringReqTD = try nodeReqTD.nextElementSibling(), // to get stars
                      let nodeSlotSmall = nodeSlotTD.children().first()
                else {
                    print("unable to get element in lines 185 - 188")
                    continue
                }
                
                // MARK: Get Location
                var itemLocation = ""
                for child in nodeSlotSmall.children() {
                    if child.tagName() == "br" {
                        continue
                    }
                    let childText = try child.text()
                    if childText.contains(":") {
                        continue
                    } else {
                        itemLocation = childText
                    }
                }

                // MARK: Get Coords
                let thisSmallText = try nodeSlotSmall.text()
                var x: Int = 0, y: Int = 0
                if let openParenIndex = thisSmallText.lastIndex(of: "("),
                   let closeParenIndex = thisSmallText.lastIndex(of: ")") {
                    let coordStartIndex = thisSmallText.index(after: openParenIndex)
                    let coordEndIndex = thisSmallText.index(before: closeParenIndex)
                    let coords = thisSmallText[coordStartIndex...coordEndIndex].components(separatedBy: "-")
                    if coords.count <= 1 {
                        x = 0
                        y = 0
                    } else {
                        x = Int(Float(coords[0]) ?? 0)
                        y = Int(Float(coords[1]) ?? 0)
                    }
                } else {
                    print("unable to get elements in lines 212 - 213")
                    missedNodes.append(testItem)
                    return
                }

                // get Time
                let thisTD2Text = try nodeReqTD.text()
                var time: Int? = nil
                var timeOfDay = ""
                var itemTimes: [Int?] = []
                if thisTD2Text.contains("AM") || thisTD2Text.contains("PM") {
                    for thisTime in thisTD2Text.components(separatedBy: "/") {
                        for component in thisTime.components(separatedBy: " ") {
                            if let timeInt = Int(component) {
                                time = timeInt
                            } else if component == "AM" || component == "PM" {
                                timeOfDay = component
                            }
                        }
                        if timeOfDay == "AM" {
                            itemTimes.append(time)
                        } else if timeOfDay == "PM" {
                            if let time = time {
                                itemTimes.append(time + 12)
                            }
                        }
                    }
                }

                // get stars
                let thisTD3Elements = try gatheringReqTD.text().components(separatedBy: " Perception ")
                let itemStars = thisTD3Elements[0].components(separatedBy: " ").last?.count ?? 0

                if itemTimes.isEmpty {
                    let locationInfo = NodeLocationInfo(time: time, location: itemLocation, source: itemSource, stars: itemStars, x: x, y: y)
                    itemLocationInfo.append(locationInfo)
                } else {
                    for time in itemTimes {
                        let locationInfo = NodeLocationInfo(time: time, location: itemLocation, source: itemSource, stars: itemStars, x: x, y: y)
                        itemLocationInfo.append(locationInfo)
                    }
                }
            }
        }

        for itemLocation in itemLocationInfo {
            let gatheringItem = GatheringNode(name: itemName, time: itemLocation.time, location: itemLocation.location, img: itemImgUrl, description: itemDescription, type: itemType, source: itemLocation.source, lvl: itemLvl, stars: itemLocation.stars, x: itemLocation.x, y: itemLocation.y, expac: itemExpac, gathering: 0)
                nodes.append(gatheringItem)
        }
    }
}
