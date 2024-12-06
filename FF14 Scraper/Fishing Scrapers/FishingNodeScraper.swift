//
//  FishingNodeScraper.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/28/21.
//

import Foundation
import SwiftSoup

class FishingNodeScraper {
    private var nodes: [FishingNode] = []
    private var missedNodes: [String] = []
    private let type = ["Submersible Components", "Bone", "Cloth", "Dye", "Ingredient", "Leather", "Lumber", "Metal", "Part", "Reagent", "Seafood", "Stone"]
    
    func scrapeGatheringNodesWiki() {
        let testing = true
        if testing {
            guard let item = "/wiki/Dark_Knight_(Seafood)".removingPercentEncoding
            else {
                print("failed to format item")
                return
            }

            do {
                try scrapeFishingNode(item: item, name: "Dark Knight (Seafood)")
                print(nodes)
            } catch {
                print("Error scraping fishing node: ", error)
            }
        } else {
            let fm = FileManager.default
            lazy var path: URL = {
                fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
            }()
            let filenames = ["FishingNodesFolklore.json", "EphemeralFishingNodes.json", "FishingNodesUnspoiled.json", "FishingCollectiblesNormal.json", "FishingNodesNormal.json"]
            var nodesToSearch: [String : String] = [:]

            for filename in filenames {
                let jsonDecoder = JSONDecoder()

                // Get JSON
                guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent(filename).path) else { return }

                // decode JSON
                do {
                    let data = Data(jsonData)
                    let itemNames = try jsonDecoder.decode([String: String].self, from: data)
                    nodesToSearch.merge(itemNames) { (current, _) in current }
                } catch let error {
                    NSLog("\(error)")
                }
            }

            let group = DispatchGroup()
            for (name, address) in nodesToSearch {
                group.enter()
                DispatchQueue.global().async { [weak self] in
                    guard let self else { return }

                    do {
                        try scrapeFishingNode(item: address, name: name)
                    } catch {
                        print("error scraping fishing node: ", error)
                    }

                    Thread.sleep(forTimeInterval: 2.0)
                }
                group.leave()
            }

            do {
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
            } catch {
                print("error saving data to file: ", error)
            }
        }
    }

    private func scrapeFishingNode(item: String, name: String) throws {
        // scrape GamerEscape wiki
        let consoleGamesWikiURL = URL(string: "https://ffxiv.consolegameswiki.com")!
        let consoleGamesWikiItemURL = consoleGamesWikiURL.appendingPathComponent(item)
        let consoleGamesHTML = try String(contentsOf: consoleGamesWikiItemURL)
        let document = try SwiftSoup.parse(consoleGamesHTML)

        // Get item elements
        guard let contentDiv = try document.select("#mw-content-text").first(),
              let parserDiv = contentDiv.children().first(),
              let infoBox = parserDiv.children().first(),
              let imageDiv = try infoBox.children().first()?.nextElementSibling(),
              let imageA = imageDiv.children().first()?.children().first(),
              let headingP = try imageDiv.nextElementSibling(),
              let statsDiv = try headingP.nextElementSibling(),
              let listWrapperDiv = try statsDiv.nextElementSibling(),
              let boxList = listWrapperDiv.children().first()
        else{
            print("unable to get content lines 70-71")
            missedNodes.append(item)
            return
        }

        // get image url
        let itemImgUrl: String = try imageA.attr("href")

        // get itemType
        let listItems = boxList.children()
        let itemType: String
        let itemExpac: Int

        for listItem in listItems {
            switch listItem.tagName() {
                case "dt":
                    guard let itemDD = try? listItem.nextElementSibling(),
                          let itemDDText = try? listItem.text()
                    else {
                        print("unable to get next item")
                        continue
                    }
                    let itemText = try listItem.text()

                    if itemText.lowercased().contains("type") {
                        let itemDDText = try listItem.text()
                        print("itemDDText (type): ", itemDDText)
                    } else if itemText.lowercased().contains("patch") {
                        print("itemDDText (patch): ", itemDDText)
                    }
                default:
                    continue
            }
        }
        print(boxList)


//            let locationInfo = FishingNodeLocationInfo(time: itemTime, location: itemLocation, source: itemSource, stars: itemStars, x: x, y: y, duration: itemDuration, weather: itemWeather, mooch: itemMooch, bait: itemBait, waterType: itemWaterType)
//            itemLocationInfo.append(locationInfo)


//        for itemLocation in itemLocationInfo {
//            guard let itemLocation = itemLocation as? FishingNodeLocationInfo else { continue }
//            let fishingItem = FishingNode(
//                id: nodes.count,
//                name: name,
//                time: itemLocation.time,
//                duration: itemLocation.duration,
//                location: itemLocation.location,
//                img: itemImgUrl,
//                description: itemDescription,
//                type: itemType,
//                source: itemLocation.source,
//                lvl: itemLvl,
//                stars: itemStars,
//                x: itemLocation.x,
//                y: itemLocation.y,
//                expac: itemExpac,
//                desynthLvl: itemLvl,
//                desynthJob: itemDesynth,
//                mooch: itemLocation.mooch,
//                moochFrom: itemLocation.bait,
//                weather: itemLocation.weather,
//                waterType: itemLocation.waterType
//            )
//            nodes.append(fishingItem)
//        }
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
