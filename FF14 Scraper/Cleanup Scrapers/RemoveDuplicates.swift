//
//  RemoveDuplicates.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/16/22.
//

import Foundation

class RemoveDuplicates {
    private let fm = FileManager.default
    private lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let fileNames = ["Botany", "Mining", "Fishing"]

    func fixDuplicates() throws {
        for fileName in fileNames {
            let nodesToModify = getNodes(fileName: fileName)
            let finalNodes = removeDuplicates(nodesToModify: nodesToModify)
            try encodeAndSave(finalNodes: finalNodes, fileName: fileName)
        }
    }

    private func getNodes(fileName: String) -> [Node] {
        let decoder = JSONDecoder()

        // Get JSON data
        guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent("All\(fileName)Nodes.json").path)
        else {
            print("Failed to get JSON data from file")
            return []
        }
        // Decode JSON
        do {
            let data = Data(jsonData)
            let nodesToModify: [Node]
            if fileName == "Fishing" {
                nodesToModify = try decoder.decode([FishingNode].self, from: data)
            } else {
                nodesToModify = try decoder.decode([GatheringNode].self, from: data)
            }
            return nodesToModify
        } catch let error {
            NSLog("\(error)")
            return []
        }
    }

    private func removeDuplicates(nodesToModify: [Node]) -> [Node] {
        var nodeDict: [String: [Node]] = [:]
        for node in nodesToModify {
            if let entries = nodeDict[node.name] {
                var isInDict = false
                for entry in entries {
                    if node.name == entry.name &&
                        node.time == entry.time &&
                        node.location == entry.location &&
                        node.x == entry.x &&
                        node.y == entry.y {
                        isInDict = true
                    }
                }
                if !isInDict {
                    nodeDict[node.name]?.append(node)
                }
            } else {
                nodeDict[node.name] = [node]
            }
        }

        var finalNodes: [Node] = []
        for entry in nodeDict {
            for node in entry.value {
                finalNodes.append(node)
            }
        }
        return finalNodes
    }

    private func encodeAndSave(finalNodes: [Node], fileName: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let json: Data
        if fileName == "Fishing" {
            json = try encoder.encode(finalNodes as? [FishingNode])
        } else {
            json = try encoder.encode(finalNodes as? [GatheringNode])
        }
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/All\(fileName)Nodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
}
