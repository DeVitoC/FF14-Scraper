//
//  UpdateFishingDescription.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/15/22.
//

import Foundation

class UpdateFishingDescription {
    private let fm = FileManager.default
    private lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let fileName = "AllFishingNodes.json"

    func fixFishDesc() throws {
        let nodesToModify = getNodes()
        let finalNodes = fixDescription(nodesToModify: nodesToModify)
        try encodeAndSave(finalNodes: finalNodes)
    }

    private func getNodes() -> [FishingNode] {
        let decoder = JSONDecoder()

        // Get JSON data
        guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent(fileName).path)
        else {
            print("Failed to get JSON data from file")
            return []
        }
        // Decode JSON
        do {
            let data = Data(jsonData)
            let nodesToModify = try decoder.decode([FishingNode].self, from: data)
            return nodesToModify
        } catch let error {
            NSLog("\(error)")
            return []
        }
    }

    private func fixDescription(nodesToModify: [FishingNode]) -> [FishingNode] {
        var finalNodes: [FishingNode] = []
        for node in nodesToModify {
            var newNode = node
            var description = node.description
            var openBracktIndices: [String.Index] = []

            for (index, char) in description.enumerated() {
                if char == "[" {
                    let prevIndex = description.index(description.startIndex, offsetBy: index)
                    openBracktIndices.append(prevIndex)
                }
            }
            openBracktIndices.reverse()

            for index in openBracktIndices {
                description.insert(contentsOf: "\n\n", at: index)
            }

            newNode.description = description
            finalNodes.append(newNode)
        }
        return finalNodes
    }

    private func encodeAndSave(finalNodes: [FishingNode]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(finalNodes)
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/AllFishingNodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
}
