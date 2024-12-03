//
//  FishingNodeScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/28/21.
//

import Foundation
import SwiftSoup

class FishingNodeScraper {
//    private var nodesToSearch: [String: String] = [:]
    private var nodes: [FishingNode] = []
    private var missedNodes: [String] = []
    private let type = ["Submersible Components", "Bone", "Cloth", "Dye", "Ingredient", "Leather", "Lumber", "Metal", "Part", "Reagent", "Seafood", "Stone"]
    
    func scrapeGatheringNodesWiki() throws {
        guard let gamerEscapeWikiURL = URL(string: "https://ffxiv.consolegameswiki.com")
        else { return }
        let fm = FileManager.default
        lazy var path: URL = {
            fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        }()
        let filenames = ["FishingNodesFolklore.json", "EphemeralFishingNodes.json", "FishingNodesUnspoiled.json", "FishingCollectiblesNormal.json", "FishingNodesNormal.json"]

        for filename in filenames {
            let jsonDecoder = JSONDecoder()

            // Get JSON
            guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent(filename).path) else { return }

            // decode JSON
            do {
                let data = Data(jsonData)
                let itemNames = try jsonDecoder.decode([String: String].self, from: data)
                for (_, address) in itemNames {
                    try scrapeGatheringNodes(gamerEscapeURL: gamerEscapeWikiURL, testItem: address)
                    let seconds = 2.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {}
                }
            } catch let error {
                NSLog("\(error)")
            }
        }

//        try scrapeGatheringNodes(gamerEscapeURL: gamerEscapeWikiURL, testItem: "/wiki/Dark_Knight_(Seafood)")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(nodes)
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/AllFishingNodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)

        let missedNodesJson = try encoder.encode(missedNodes)
        let missedNodesJsonString = String(decoding: missedNodesJson, as: UTF8.self)
        let missedNodesFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/MissedNodesFishing.json")
        try missedNodesJsonString.write(to: missedNodesFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeGatheringNodes(gamerEscapeURL: URL, testItem: String) throws {
        // scrape GamerEscape wiki
        let gamerEscapeWikiItemURL = gamerEscapeURL.appendingPathComponent(testItem)
        let gamerEscapeHTML = try String(contentsOf: gamerEscapeWikiItemURL)
        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)

        let itemName = testItem.replacingOccurrences(of: "/wiki/", with: "")

        // Get item elements
        guard let divGE1 = try gamerEscapeDocument.select("#mw-content-text").first(),
              let divGE2 = divGE1.children().first()
        else{
            print("unable to get gamerEscape content text div lines 70-71")
            missedNodes.append(testItem)
            return
        }
        var tableGE1: Element
        if divGE2.children().first()?.tagName() == "table" {
            guard let tempTable = divGE2.children().first()
            else {
                print("Unable to get gamerEscape content text table line 104")
                missedNodes.append(testItem)
                return
            }
            tableGE1 = tempTable
        } else if divGE2.children().first()?.tagName() == "div" {
            guard let tempTable = try divGE2.children().first()?.nextElementSibling()
            else {
                print("unable to get gamerescape content text table line 115")
                missedNodes.append(testItem)
                return
            }
            tableGE1 = tempTable
        } else {
            print("unable to get gamerescape content table line 115")
            missedNodes.append(testItem)
            return
        }

        guard let tbodyGE1 = tableGE1.children().first(),
              let trGE1 = tbodyGE1.children().first(),
              let tdGE1 = trGE1.children().first(),
              let tableGE2 = tdGE1.children().first(),
              let tbodyGE2 = tableGE2.children().first(),
              let trGE2 = tbodyGE2.children().first(),
              let tdGE2 = trGE2.children().first(),
              let aGE1 = tdGE2.children().first(),
              let tdGE3 = try tdGE1.nextElementSibling(),
              let aGE2 = tdGE3.children().first(),
              let divGE3 = try aGE2.nextElementSibling()?.nextElementSibling(),
              let tdGE4 = try tdGE2.nextElementSibling(),
              let divGE4 = tdGE4.children().last(),
              let trGE3 = try trGE1.nextElementSibling()?.nextElementSibling(),
              let tbodyGE3 = trGE3.children().first()?.children().first()?.children().first()
        else {
            print("unable to get element in lines 98 - 115")
            missedNodes.append(testItem)
            return
        }

        // Get description
        guard let descriptionTR = tbodyGE1.children().last(),
              let descriptionTD = descriptionTR.children().first(),
              let descriptionTable = descriptionTD.children().first(),
              let descriptionTbody = descriptionTable.children().first(),
              descriptionTbody.children().count > 3
        else {
            print("unable to get element in line 123-127")
            missedNodes.append(testItem)
            return
        }
        let descriptionTR2 = descriptionTbody.children()[2]
        let itemDescription = try descriptionTR2.text()

        // assign item values
        let itemImgUrl = try aGE1.attr("href")
        let patchText = try divGE3.text().components(separatedBy: " ")[1]
        guard let patchNumber = Float(patchText) else { return }
        let itemExpac = Int(patchNumber - 2)
        let itemType = try divGE4.text()
        var itemLvl: Int = 0
        for div1 in tbodyGE3.children() {
            guard let td1 = div1.children().first(),
                  try td1.text().contains("Item Level"),
                  let td2 = try td1.nextElementSibling(),
                  let td2Text = Int(try td2.text())
            else {
                continue
            }
            itemLvl = td2Text
        }
        
        // get gathering location elements
        var itemLocationInfo: [LocationInfo] = []
        guard let divGE5 = try gamerEscapeDocument.select("#Fishing").first() else { print("line 142"); missedNodes.append(testItem); return }
        guard let tdGE5 = divGE5.parent()
        else {
            print("unable to get element in lines 143")
            missedNodes.append(testItem)
            return
        }
        
        guard let headerDivGE1 = try tdGE5.children().first()?.nextElementSibling(),
              let headerTbodyGE1 = headerDivGE1.children().first()?.children().first()
        else {
            print("unable to get element in line 150 - 151")
            missedNodes.append(testItem)
            return
        }
        
        // get stars
        var itemStars: Int = 0
        for element in headerTbodyGE1.children() {
            if try element.children().first()?.text().contains("Level") != false {
                let levelText = try element.children()[0].text().components(separatedBy: ": ")
                if levelText.count > 1 {
                    let level = levelText[1]
                    let levelComponents = level.components(separatedBy: " ")
                    if levelComponents.count > 1 {
                        itemStars = Int(levelComponents[1]) ?? 0
                    }
                } else {
                    itemStars = 0
                }
            }
        }

        // get location information
        for (index, div1) in tdGE5.children().enumerated() { // temp
            guard index > 2,
                  let locationTbody = div1.children().first()?.children().first(), // to get location, water type, and coords
                  let baitTbody = try div1.children().first()?.nextElementSibling()?.children().first(), // to get bait, mooch, time, weather
                  let locationLineTR = try locationTbody.children().first()?.nextElementSibling(),
                  let locationLineTD = locationLineTR.children().first()
            else {
                continue
            }

            // get location for this node
            guard let locationAHREF = locationLineTD.children().first()
            else {
                print("unable to get element in lines 180 - 183")
//                missedNodes.append(testItem)
                continue
            }
            let itemLocation = try locationAHREF.text()

            // get water type for this node
            guard let waterTypeTD = try locationLineTD.nextElementSibling()
            else {
                continue
            }
            let itemWaterType = try waterTypeTD.text()
            let itemSource = getFishingSource(for: itemWaterType)

            // get coords
//            guard let coordsAHREF = try locationAHREF.nextElementSibling()
//            else {
//                continue
//            }

            let locationLineText = try locationLineTD.text()
            var x: Int = 0, y: Int = 0
            if let openParenIndex = locationLineText.lastIndex(of: "("),
               let closeParenIndex = locationLineText.lastIndex(of: ")") {
                let coordStartIndex = locationLineText.index(after: openParenIndex)
                let coordEndIndex = locationLineText.index(before: closeParenIndex)
                if coordEndIndex > coordStartIndex {
                    let coords = locationLineText[coordStartIndex...coordEndIndex].components(separatedBy: "-")
                    if coords.count <= 1 {
                        x = 0
                        y = 0
                    } else {
                        x = Int(Float(coords[0]) ?? 0)
                        y = Int(Float(coords[1]) ?? 0)
                    }
                } else {
                    x = 0
                    y = 0
                }
            } else {
                print("unable to get elements in lines 208 - 209")
                missedNodes.append(testItem)
                return
            }

            // get bait and mooch
//            guard let baitLineTR = baitTbody.children().first()
//            else {
//                continue
//            }
//            let baitText = (try? baitLineTR.text()) ?? ""
            var itemMooch = false
            var itemBait: [String] = []
            var itemTime: Int? = nil
            var itemDuration: Int = 0
            var itemWeather: [String] = []

            for childTR in baitTbody.children() {
                let childTRText = (try? childTR.text()) ?? ""

                if childTRText.contains("Bait") {
                    // Get Mooch
                    itemMooch = childTRText.contains("Mooch")

                    // Get bait
                    if !itemMooch {
                        let strippedBaitText = childTRText.replacingOccurrences(of: "Bait: ", with: "")
                        itemBait = strippedBaitText.components(separatedBy: ",  ")
                    }
                } else if childTRText.contains("Mooch") {
                    guard let childTD = childTR.children().first()
                    else {
                        continue
                    }
                    for child in childTD.children() {
                        let childText = (try? child.text()) ?? ""

                        if child.tagName() == "a" || childText == "►" {
                            continue
                        }

                        guard let baitA = child.children().first()?.children().first()
                        else {
                            continue
                        }
                        let baitTitle = try baitA.attr("title")
                        let strippedBaitTitle = baitTitle.replacingOccurrences(of: "HQ ", with: "")
                        itemBait.append(strippedBaitTitle)
                    }
                } else if childTRText.contains("Conditions") {
                    // get Time
                    let conditionsText = childTRText.replacingOccurrences(of: "Conditions: ", with: "")
                    let timesText = conditionsText.components(separatedBy: ",")[0]
                    let timeStrings = timesText.components(separatedBy: "-")

                    // Make sure there is a start and end time
                    if timeStrings.count < 2 {
                        continue
                    }

                    // Get start time
                    let startTimeString = timeStrings[0]
                    let strippedStartString = startTimeString.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "")
                    var startInt = Int(strippedStartString) ?? 0
                    let startTimeOfDay = startTimeString.replacingOccurrences(of: "\(startInt)", with: "")
                    if startTimeOfDay == "AM" {
                        itemTime = startInt
                    } else if startTimeOfDay == "PM" {
                        startInt += 12
                        itemTime = startInt
                    }

                    // Get duration
                    let endTimeString = timeStrings[1]
                    let strippedEndString = endTimeString.replacingOccurrences(of: "AM", with: "").replacingOccurrences(of: "PM", with: "")
                    var endInt = Int(strippedEndString) ?? 0
                    let endTimeOfDay = endTimeString.replacingOccurrences(of: "\(endInt)", with: "")
                    if endTimeOfDay == "PM" {
                        endInt += 12
                    }
                    itemDuration = endInt > startInt ? endInt - startInt : endInt + 24 - startInt
                } else if childTRText.contains("Weather") {
                    // Get weather
                    var weatherStringStripped = childTRText.replacingOccurrences(of: "Weather: ", with: "")
                    weatherStringStripped = weatherStringStripped.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                    itemWeather.append(weatherStringStripped)
                }
            }

            let locationInfo = FishingNodeLocationInfo(time: itemTime, location: itemLocation, source: itemSource, stars: itemStars, x: x, y: y, duration: itemDuration, weather: itemWeather, mooch: itemMooch, bait: itemBait, waterType: itemWaterType)
            itemLocationInfo.append(locationInfo)
        }

        guard let desynthTitleSpan = try gamerEscapeDocument.select("#Desynth").first(),
              let desynthTitleDiv = desynthTitleSpan.parent(),
              let desynthTitleTh = desynthTitleDiv.parent(),
              let desynthTitleTR = desynthTitleTh.parent(),
              let desynthElementTR = try desynthTitleTR.nextElementSibling(),
              let desynthElementTD = desynthElementTR.children().first(),
              let desynthElementDiv = desynthElementTD.children().first(),
              let desynthElementTable = desynthElementDiv.children().first(),
              let desynthElementTbody = desynthElementTable.children().first(),
              let desynthElementTR2 = desynthElementTbody.children().first(),
              let desynthElementTD2 = desynthElementTR2.children().first(),
              let desynthElementTable2 = desynthElementTD2.children().first(),
              let desynthElementTbody2 = desynthElementTable2.children().first(),
              let desynthElementTR3 = desynthElementTbody2.children().first(),
              let desynthElementTD3 = desynthElementTR3.children().first(),
              let desynthElementTD4 = try desynthElementTD3.nextElementSibling()
        else {
            print("unable to find Desynth in gamerescape document")
            missedNodes.append(testItem)
            return
        }
        let itemDesynth = try desynthElementTD4.text()

        for itemLocation in itemLocationInfo {
            guard let itemLocation = itemLocation as? FishingNodeLocationInfo else { continue }
            let fishingItem = FishingNode(
                id: nodes.count,
                name: itemName,
                time: itemLocation.time,
                duration: itemLocation.duration,
                location: itemLocation.location,
                img: itemImgUrl,
                description: itemDescription,
                type: itemType,
                source: itemLocation.source,
                lvl: itemLvl,
                stars: itemStars,
                x: itemLocation.x,
                y: itemLocation.y,
                expac: itemExpac,
                desynthLvl: itemLvl,
                desynthJob: itemDesynth,
                mooch: itemLocation.mooch,
                moochFrom: itemLocation.bait,
                weather: itemLocation.weather,
                waterType: itemLocation.waterType
            )
            nodes.append(fishingItem)
        }
    }

    /// Private method to get fishing source based on water type fish is found in
    /// - Parameter waterType: String that descriptes the type of water the fish is found in
    /// - Returns: String that descripes the fishing source
    private func getFishingSource(for waterType: String) -> String {
        switch waterType {
            case "Saltwater", "Freshwater":
                return "Fishing"
            case "Aetherfishing":
                return "Aetherfishing"
            case "Cloudfishing":
                return "Cloudfishing"
            case "Dunefishing":
                return "Dunefishing"
            case "Magma":
                return "Hellfishing"
            case "Skies":
                return "Skyfishing"
            case "Starfishing":
                return "Starfishing"
            default:
                return ""
        }
    }
}
