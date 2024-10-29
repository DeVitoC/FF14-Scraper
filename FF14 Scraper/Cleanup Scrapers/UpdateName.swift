//
//  UpdateName.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/15/22.
//

import Foundation

class UpdateName {
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
        fixName()
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
