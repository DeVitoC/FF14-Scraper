//
//  AddWeatherChain.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/17/22.
//

import Foundation

class AddWeatherChain {
    private let fm = FileManager.default
    private lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let fileName = "AllFishingNodes.json"

    func fixWeather() throws {
        let nodesToModify = getNodes()
        let finalNodes = addWeatherChainBool(nodesToModify: nodesToModify)
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

    private func addWeatherChainBool(nodesToModify: [FishingNode]) -> [FishingNodeWC] {
        var finalNodes: [FishingNodeWC] = []
        for node in nodesToModify {
            var isWeatherChain: Bool
            var weatherChain: [String]
            var weather: [String]
            if node.weather.isEmpty {
                isWeatherChain = false
                weatherChain = []
                weather = []
            } else if node.weather[0].contains("Weather Chain:") {
                isWeatherChain = true
                let splitWeather = splitWeatherChain(forChain: node.weather[0])
                weatherChain = splitWeather.weatherChain
                weather = splitWeather.weather
            } else {
                isWeatherChain = false
                weatherChain = []
                weather = node.weather
            }

            let newFishingNode = FishingNodeWC(
                id: finalNodes.count,
                name: node.name,
                time: node.time,
                duration: node.duration,
                location: node.location,
                img: node.img,
                description: node.description,
                type: node.type,
                source: node.source,
                lvl: node.lvl,
                stars: node.stars,
                x: node.x,
                y: node.y,
                expac: node.expac,
                desynthLvl: node.desynthLvl,
                desynthJob: node.desynthJob,
                mooch: node.mooch,
                moochFrom: node.moochFrom,
                isWeatherChain: isWeatherChain,
                weather: weather,
                weatherChain: weatherChain,
                waterType: node.waterType
            )
            finalNodes.append(newFishingNode)
        }
        return finalNodes
    }

    private func splitWeatherChain(forChain weatherChain: String) -> (weatherChain: [String], weather: [String]) {
        let weatherChainString = weatherChain.replacingOccurrences(of: "Weather Chain: ", with: "")
        let weatherParts = weatherChainString.components(separatedBy: "►")
        let weatherChainRaw = weatherParts[0].components(separatedBy: " or ")
        let weatherRaw = weatherParts[1].components(separatedBy: " or ")
        var weatherChainTrimmed: [String] = []
        var weatherTrimmed: [String] = []
        for item in weatherChainRaw {
            var newString: String = item
            if item.hasPrefix(" ") {
                newString.removeFirst()
            }
            if item.hasSuffix(" ") {
                newString.removeLast()
            }
            weatherChainTrimmed.append(newString)
        }
        for item in weatherRaw {
            var newString: String = item
            if item.hasPrefix(" ") {
                newString.removeFirst()
            }
            if item.hasSuffix(" ") {
                newString.removeLast()
            }
            weatherTrimmed.append(newString)
        }
        return (weatherChainTrimmed, weatherTrimmed)
    }

    private func encodeAndSave(finalNodes: [FishingNodeWC]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let json = try encoder.encode(finalNodes)
        let jsonString = String(decoding: json, as: UTF8.self)

        let outputFile = URL(fileURLWithPath: "/Users/christopherdevito/Desktop/AllFishingNodes.json")
        try jsonString.write(to: outputFile, atomically: true, encoding: String.Encoding.utf8)
    }
}
