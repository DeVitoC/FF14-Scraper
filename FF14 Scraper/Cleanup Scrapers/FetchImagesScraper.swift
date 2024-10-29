//
//  FetchImages.swift
//  FF14 Scraper
//
//  Created by Christopher DeVito on 2/10/22.
//

import Foundation
import SwiftSoup
import CoreGraphics
import CoreImage

class FetchImagesScraper {
    var nodes: [GatheringNode] = []
    var missedNodes: [URL] = []
    let fm = FileManager.default
    lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    let fileName = "AllBotanyNodes.json"
    let saveFilePath = "ff14Images/JPG"

    func fetchFromJSONFile() {
        let decoder = JSONDecoder()

        // Get JSON data
        guard let jsonData = NSData(contentsOfFile: path.appendingPathComponent(fileName).path)
        else {
            print("Failed to get JSON data from file")
            return
        }

        // Decode JSON
        do {
            let data = Data(jsonData)
            nodes = try decoder.decode([GatheringNode].self, from: data)
        } catch let error {
            NSLog("\(error)")
        }

        fetchImages()
    }

    private func fetchImages() {
        for node in nodes {
            fetchImageFromURL(node: node)
        }
    }

    private func fetchImageFromURL(node: GatheringNode) {
        let baseURL = URL(string: "https://ffxiv.gamerescape.com")!
        let url = baseURL.appendingPathComponent(node.img)
        var imageLocation: String? = nil

        do {
            imageLocation = try scrapeAndFetchImage(forURL: url)
        } catch {
            print("\(error)")
        }

        guard let imageLocation = imageLocation,
              imageLocation != "fail"
        else {
            print("imageLocation not valid")
            return
        }
        let imageLocationURL = baseURL.appendingPathComponent(imageLocation)

        DispatchQueue.global().async {
            print("inside")
            if let image = CIImage(contentsOf: imageLocationURL) {
                print("image is valid")
                    self.saveImageToDisk(image: image, name: node.name)
            } else {
                print("failing")
            }
        }
        sleep(3)

        print("outside")
        return
    }

    private func saveImageToDisk(image: CIImage, name: String) {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            print("failed to get colorSpace")
            return
        }
        let strippedName = name.replacingOccurrences(of: " ", with: "")
        let path = path.appendingPathComponent(saveFilePath, isDirectory: true).appendingPathComponent(strippedName).appendingPathExtension("jpg")
        print(path)
        let context = CIContext()

        do {
            try context.writeJPEGRepresentation(of: image, to: path, colorSpace: colorSpace)
        } catch {
            print("error writing as jpg")
        }
    }

    private func scrapeAndFetchImage(forURL url: URL) throws -> String? {
        // scrape GamerEscape wiki
        let gamerEscapeHTML = try String(contentsOf: url)
        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)

        // Get item elements
        guard let mainContentDiv = try gamerEscapeDocument.select("#mw-content-text").first(),
              let imageDiv = try mainContentDiv.children().first()?.nextElementSibling(),
              let imageA = imageDiv.children().first()
        else{
            print("unable to get gamerEscape content text div lines 73-75")
            missedNodes.append(url)
            return "fail"
        }

        let imageHREF = try imageA.attr("href")
        return imageHREF
    }
}
