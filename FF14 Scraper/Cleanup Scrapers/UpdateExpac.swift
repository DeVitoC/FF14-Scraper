//
//  UpdateExpac.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/11/22.
//

import Foundation

class UpdateExpac {
    private var listToCheck: [String] = []
    private let fm = FileManager.default
    private lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let fileNames = ["Botany", "Mining", "Fishing"]
    let decoder = JSONDecoder()

    func fixExpacData() throws {
        for file in fileNames {
            print("file: ", file)
            let nodesToUpdate: [Node]

            if file == "Fishing" {
                nodesToUpdate = getFishingNodes(fileName: file)
            } else {
                nodesToUpdate = getNodes(fileName: file)
            }

            print("nodesToUpdate: ", nodesToUpdate)
            let updatedNodes = fixExpacNumber(nodesToModify: nodesToUpdate)
            try encodeAndSave(finalNodes: updatedNodes, fileName: file)
        }
    }

    private func getNodes(fileName: String) -> [GatheringNode] {
        let data = loadFileData(fileName: fileName)
        // Decode JSON
        do {
            let nodes = try decoder.decode([GatheringNode].self, from: data)
            return nodes
        } catch let error {
            NSLog("\(error)")
            return []
        }
    }

    private func getFishingNodes(fileName: String) -> [FishingNode] {
        let data = loadFileData(fileName: fileName)
        // Decode JSON
        do {
            let nodes = try decoder.decode([FishingNode].self, from: data)
            return nodes
        } catch let error {
            NSLog("\(error)")
            return []
        }
    }

    private func loadFileData(fileName: String) -> Data {
        guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent("All\(fileName)Nodes.json").path)
        else {
            print("Failed to get JSON data from file")
            return Data()
        }
        return Data(jsonData)
    }

    private func fixExpacNumber(nodesToModify: [Node]) -> [Node] {
        var finalNodes: [Node] = []
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
            case "Tuliyollal", "Urqopacha", "Yak T'el", "Kozama'uka", "Shaaloani", "Heritage Found", "Living Memory":
                newNode.expac = 5
            default:
                listToCheck.append(newNode.name)
            }
            finalNodes.append(newNode)
        }
        return finalNodes
    }

    private func encodeAndSave(finalNodes: [Node], fileName: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var json: Data
        if fileName == "Fishing" {
            json = try encoder.encode(finalNodes as? [FishingNode] ?? [])
        } else {
            json = try encoder.encode(finalNodes as? [GatheringNode] ?? [])
        }
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/All\(fileName)Nodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)

        let missedNodesJson = try encoder.encode(listToCheck)
        let missedNodesJsonString = String(decoding: missedNodesJson, as: UTF8.self)
        let missedNodesFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/\(fileName)NodesToCheckExpac.json")
        try missedNodesJsonString.write(to: missedNodesFile, atomically: true, encoding: String.Encoding.utf8)
    }
}
