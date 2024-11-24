//
//  UpdateName.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/15/22.
//

import Foundation

class UpdateName {
    private let fm = FileManager.default
    private lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let fileNames = ["Botany", "Mining", "Fishing"]

    func fixNames() throws {
        for fileName in fileNames {
            let nodesToModify = getNodes(fileName: fileName)
            let finalNodes = fixName(nodesToModify: nodesToModify)
            try encodeAndSave(finalNodes: finalNodes, fileName: fileName)
        }
    }

    private func getNodes(fileName: String) -> [Node] {
        let decoder = JSONDecoder()

        // Get JSON data
        guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent("All\(fileName)Nodes.json").path)
        else {
            print("Failed to get JSON data from file, ", fileName)
            return []
        }
        print("got data")
        // Decode JSON
        do {
            let data = Data(jsonData)
            let nodesToModify: [Node]
            if fileName == fileNames[2] {
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

    private func fixName(nodesToModify: [Node]) -> [Node] {
        var finalNodes: [Node] = []
        for node in nodesToModify {
            var newNode = node
            newNode.name = node.name.replacingOccurrences(of: "_", with: " ")
            finalNodes.append(newNode)
        }

        return finalNodes
    }

    private func encodeAndSave(finalNodes: [Node], fileName: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let json: Data
        if fileName == fileNames[2] {
            json = try encoder.encode(finalNodes as! [FishingNode])
        } else {
            json = try encoder.encode(finalNodes as! [GatheringNode])
        }
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/All\(fileName)Nodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
}
