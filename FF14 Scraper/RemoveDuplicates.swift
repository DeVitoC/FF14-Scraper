//
//  RemoveDuplicates.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/16/22.
//

import Foundation

class RemoveDuplicates {
    private var finalNodes: [FishingNode] = []
    private var nodesToModify: [FishingNode] = []
    private var listToCheck: [String] = []
    private let fm = FileManager.default
    private lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let fileName = "AllFishingNodes.json"

    func fixDuplicates() throws {
        getNodes()
        print(nodesToModify.count)
        removeDuplicates()
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

    private func removeDuplicates() {
        var nodeDict: [String: [FishingNode]] = [:]
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

        for entry in nodeDict {
            for node in entry.value {
                finalNodes.append(node)
            }
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
