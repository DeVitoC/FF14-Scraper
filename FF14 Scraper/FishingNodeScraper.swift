//
//  FishingNodeScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/28/21.
//

import Foundation
import SwiftSoup

class FishingNodeScraper {
    var nodesToSearch: [String: String] = [:]
    var nodes: [FishingNode] = []
    var missedNodes: [String] = []
    let locations = ["Limsa Lominsa Upper Decks", "Limsa Lominsa Lower Decks", "Eastern La Noscea", "Lower La Noscea", "Middle La Noscea", "Upper La Noscea", "Western La Noscea", "Outer La Noscea", "New Gridania", "Old Gridania", "Central Shroud", "East Shroud", "North Shroud", "South Shroud", "Central Thanalan", "Eastern Thanalan", "Northern Thanalan", "Southern Thanalan", "Western Thanalan", "The Lavender Beds", "Coerthas Central Highlands", "Coerthas Western Highlands", "Mor Dhona", "Mists", "Labender Beds", "The Dravanian Forelands", "The Dravanian Hinterlands", "The Churning Mists", "The Sea of Clouds", "The Fringes", "The Peaks", "The Ruby Sea", "The Azim Steppe", "Yanxia", "The Lochs", "Amh Araeng", "Lakeland", "Kholusia", "Il Mheg", "The Rak'tika Greatwood", "Labyrinthos", "Thavnair", "Garlemald", "Azys Lla", "The Tempest", "Rhalgr's Reach"]
    let type = ["Submersible Components", "Bone", "Cloth", "Dye", "Ingredient", "Leather", "Lumber", "Metal", "Part", "Reagent", "Seafood", "Stone"]
    
    func scrapeGatheringNodesWiki() throws {
        guard let consoleGamesWikiURL = URL(string: "https://ffxiv.consolegameswiki.com"),
              let gamerEscapeWikiURL = URL(string: "https://ffxiv.gamerescape.com")
        else { return }
        //        let fm = FileManager.default
        //        lazy var path: URL = {
        //            fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        //        }()
        //        let filenames = ["FishingNodesFolklore.json", "FishingNodesNormal.json", "FishingCollectiblesNormal.json"]
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
        //                    try scrapeGatheringNodes(consoleGamesURL: consoleGamesWikiURL, gamerEscapeURL: gamerEscapeWikiURL, testItem: address)
        //                    let seconds = 2.0
        //                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {}
        //                }
        //            } catch let error {
        //                NSLog("\(error)")
        //            }
        //        }
        
        try scrapeGatheringNodes(consoleGamesURL: consoleGamesWikiURL, gamerEscapeURL: gamerEscapeWikiURL, testItem: "/wiki/Harbor_Herring")
        
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        let json = try encoder.encode(nodes)
//        let jsonString = String(decoding: json, as: UTF8.self)
//
//        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/AllFishingNodes.json")
//        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
//
//        let missedNodesJson = try encoder.encode(missedNodes)
//        let missedNodesJsonString = String(decoding: missedNodesJson, as: UTF8.self)
//        let missedNodesFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/MissedNodesFishing.json")
//        try missedNodesJsonString.write(to: missedNodesFile, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func scrapeGatheringNodes(consoleGamesURL: URL, gamerEscapeURL: URL, testItem: String) throws {
        // scrape consoleGames Wiki
        let consoleGamesWikiItemURL = consoleGamesURL.appendingPathComponent(testItem)
        let consoleGamesHTML = try String(contentsOf: consoleGamesWikiItemURL)
        let consoleGamesDocument = try SwiftSoup.parse(consoleGamesHTML)
        
        // get item name
        guard let h1 = try consoleGamesDocument.select("#firstHeading").first() else {
            print("unable to find firstHeading in consoleGameDocument")
            missedNodes.append(testItem)
            return
        }
        let itemName = try h1.text()
        
        // get item description
        guard let divCG1 = try consoleGamesDocument.select("#mw-content-text").first(),
              let divCG2 = divCG1.children().first(),
              let divCG3 = divCG2.children().first(),
              let blockquoteCG1 = try divCG3.nextElementSibling() else {
                  print("unable to get divs or blockquote lines 79 - 82")
                  missedNodes.append(testItem)
                  return
              }
        var itemDescription = try blockquoteCG1.text()
        itemDescription.removeFirst()
        itemDescription.removeFirst()
        itemDescription.removeSubrange(String.Index(utf16Offset: itemDescription.count - 22, in: itemDescription)...String.Index(utf16Offset: itemDescription.count - 1, in: itemDescription))
        
        // scrape GamerEscape wiki
        let gamerEscapeWikiItemURL = gamerEscapeURL.appendingPathComponent(testItem)
        let gamerEscapeHTML = try String(contentsOf: gamerEscapeWikiItemURL)
        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)
        
        // Get item elements
        guard let divGE1 = try gamerEscapeDocument.select("#mw-content-text").first(),
              let divGE2 = divGE1.children().first(),
              let tableGE1 = divGE2.children().first(),
              let tbodyGE1 = tableGE1.children().first(),
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
        var itemLocationInfo: [NodeLocationInfo] = []
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
                let level = try element.children()[0].text().components(separatedBy: ": ")[1]
                let levelComponents = level.components(separatedBy: " ")
                if levelComponents.count > 1 {
                    itemStars = Int(levelComponents[1]) ?? 0
                }
            }
        }
        
        // get location information
        for (index, div1) in tdGE5.children().enumerated() { // temp
            guard index > 2,
                  let locationTbody = div1.children().first()?.children().first(),
                  let baitTbody = try div1.children().first()?.nextElementSibling()?.children().first()
            else {
                print("index is 0 or 1 or 2")
                continue
            }
            print(div1)
            print()
            guard let thisTD1 = div1.children().first(), // to get location and coords and source
                  let thisTD2 = try thisTD1.nextElementSibling(), // to get time
                  let thisTD3 = try thisTD2.nextElementSibling(), // to get stars
                  let thisSmall = thisTD1.children().first()
            else {
//                print("unable to get element in lines 160 - 163")
                missedNodes.append(testItem)
                continue
            }
//            print(thisSmall)
            // get source and location for this node
            var itemSource = ""
            var itemLocation = ""
            for child in thisSmall.children() {
                if child.tagName() == "br" {
                    continue
                }
                let childText = try child.text()
                if childText.contains(":") {
                    let childTextElements = childText.components(separatedBy: ":")
                    itemSource = childTextElements[0]
                } else {
                    itemLocation = childText
                }
            }
            
            // get coords
            let thisSmallText = try thisSmall.text()
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
                print("unable to get elements in lines 189 - 190")
                missedNodes.append(testItem)
                return
            }
            
            // get Time
            let thisTD2Text = try thisTD2.text()
            var time = 0
            var timeOfDay = ""
            var itemTimes: [Int?] = []
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
                    itemTimes.append(time + 12)
                }
            }
            
            // get stars
            let thisTD3Elements = try thisTD3.text().components(separatedBy: " Perception ")
            let itemStars = thisTD3Elements[0].components(separatedBy: " ").last?.count ?? 0
            
            for time in itemTimes {
                let locationInfo = NodeLocationInfo(time: time, location: itemLocation, source: itemSource, stars: itemStars, x: x, y: y)
                itemLocationInfo.append(locationInfo)
                print(locationInfo)
            }
        }
        
        //        for itemLocation in itemLocationInfo {
//                    let fishingItem = FishingNode(name: itemName, time: <#T##Int?#>, duration: <#T##Int#>, location: <#T##String#>, img: itemImgUrl, description: itemDescription, type: itemType, source: <#T##String#>, lvl: itemLvl, stars: <#T##Int#>, x: <#T##Int#>, y: <#T##Int#>, expac: itemExpac, desynthLvl: <#T##Int#>, desynthJob: <#T##String#>, mooch: <#T##Bool#>, moochFrom: <#T##String#>, weather: <#T##[String]#>, waterType: <#T##String#>, gathering: <#T##Int#>)
        //                nodes.append(gatheringItem)
        //        }
    }
}
