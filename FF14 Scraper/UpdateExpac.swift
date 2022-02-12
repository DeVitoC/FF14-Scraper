//
//  UpdateExpac.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/11/22.
//

import Foundation

class UpdateExpac {
    private var finalNodes: [FishingNode] = []
    private var nodesToModify: [FishingNode] = []
    private var listToCheck: [String] = []
    private let fm = FileManager.default
    private lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let fileName = "AllFishingNodes.json"

    func fixExpacData() throws {
        getNodes()
        print(nodesToModify.count)
//        fixExpacNumber()
        fixName()
        print(finalNodes.count)
        try encodeAndSave()
    }

    private func getNodes() {
        let decoder = JSONDecoder()

        // Get JSON data
        guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent(fileName).path)
        else {
            print("Failed to get JSON data from file")
            return
        }
        print("got data")
        // Decode JSON
        do {
            let data = Data(jsonData)
            nodesToModify = try decoder.decode([FishingNode].self, from: data)
            print(nodesToModify.count)
        } catch let error {
            NSLog("\(error)")
        }
    }

    private func fixExpacNumber() {
        for node in nodesToModify {
            var newNode = node
            switch node.location {
            case "Limsa Lominsa Upper Decks", "Limsa Lominsa Lower Decks", "Lower La Noscea", "Middle La Noscea", "Eastern La Noscea", "Western La Noscea", "Outer La Noscea", "Upper La Noscea", "Mist", "Wolves' Den", "New Gridania", "Old Gridania", "Central Shroud", "North Shroud", "East Shroud", "South Shroud", "Lavender Beds", "Central Thanalan", "Western Thanalan", "Eastern Thanalan", "Southern Thanalan", "Northern Thanalan", "The Goblet", "Manderville Gold Saucer", "Coerthas Central Highlands", "Mor Dhona":
                newNode.expac = 0
            case "Coerthas Western Highlands", "Dravanian Forelands", "Dravanian Hinterlands", "The Churning Mists", "The Sea of Clouds", "Floating Continent", "Idyllshire", "Azys Lla", "The Dravanian Hinterlands", "The Dravanian Forelands":
                newNode.expac = 1
            case "Rhalgr's Reach", "The Fringes", "The Peaks", "The Lochs", "The Azim Steppe", "The Ruby Sea", "Yanxia", "The Doman Enclave", "Kugane", "Shirogane":
                newNode.expac = 2
            case "Eulmore", "The Crystarium", "Rak'tika", "Amh Araeng", "Il Mheg", "Kholusia", "Lakeland", "The Tempest", "The Rak'tika Greatwood":
                newNode.expac = 3
            case "Old Sharlayan", "Radz-at-Han", "Labyrinthos", "Thavnair", "Garlemald", "Mare Lamentorum", "Elpis", "Ultima Thule", "Empyreum":
                newNode.expac = 4
            default:
                listToCheck.append(newNode.name)
            }
            finalNodes.append(newNode)
        }
    }

    private func fixName() {
        for node in nodesToModify {
            var newNode = node
            newNode.name = node.name.replacingOccurrences(of: "_", with: " ")
            finalNodes.append(newNode)
        }
    }

    private func encodeAndSave() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(finalNodes)
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/AllFishingNodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)

        let missedNodesJson = try encoder.encode(listToCheck)
        let missedNodesJsonString = String(decoding: missedNodesJson, as: UTF8.self)
        let missedNodesFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/FishingNodesToCheck.json")
        try missedNodesJsonString.write(to: missedNodesFile, atomically: true, encoding: String.Encoding.utf8)
    }
}
