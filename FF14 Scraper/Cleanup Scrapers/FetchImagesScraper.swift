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
    private var missedNodes: [URL] = []
    private let fm = FileManager.default
    lazy var path: URL = {
        let path = fm.urls(for: .desktopDirectory, in: .userDomainMask)[0]
        return path
    }()
    private let baseURL = URL(string: "https://ffxiv.consolegameswiki.com")!
    private let fileNames = ["Botany", "Mining", "Fishing"]
    private let saveFilePath = "ff14Images/JPG"

    func fetchAllImages() {
        for fileName in fileNames {
            let nodes = fetchAndDecodeNodes(fileName: fileName)
            for node in nodes {
                do {
                    guard let imagePageURL = createImagePageURL(node: node),
                          let imageHref = try scrapeImageHREF(forURL: imagePageURL),
                          imageHref != "fail",
                          let image = fetchImage(imageLocation: imageHref)
                    else {
                        print("failed to fetch image for node: ", node.name)
                        continue
                    }
                    DispatchQueue.global().async {
                        self.saveImageToDisk(image: image, name: node.name)
                    }
                    sleep(3)
                } catch {
                    print(error)
                }
            }
        }
    }

    private func fetchAndDecodeNodes(fileName: String) -> [Node]{
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
            if fileName == "Fishing" {
                let nodes = try decoder.decode([FishingNode].self, from: data)
                return nodes
            } else {
                let nodes = try decoder.decode([GatheringNode].self, from: data)
                return nodes
            }
        } catch let error {
            NSLog("\(error)")
            return []
        }
    }

    private func createImagePageURL(node: Node) -> URL? {
        let url = baseURL.appendingPathComponent(node.img)

        return url
    }

    private func scrapeImageHREF(forURL url: URL) throws -> String? {
        // scrape  wiki
        let gamerEscapeHTML = try String(contentsOf: url)
        let gamerEscapeDocument = try SwiftSoup.parse(gamerEscapeHTML)

        // Get item elements
        guard let mainContentDiv = try gamerEscapeDocument.select("#mw-content-text").first(),
              let imageDiv = try mainContentDiv.children().first()?.nextElementSibling(),
              let imageA = imageDiv.children().first()
        else{
            print("unable to get content text div lines 82-84", url)
            missedNodes.append(url)
            return "fail"
        }

        let imageHREF = try imageA.attr("href")
        return imageHREF
    }

    private func fetchImage(imageLocation: String) -> CIImage? {
        let imageLocationURL = baseURL.appendingPathComponent(imageLocation)
        let image = CIImage(contentsOf: imageLocationURL)
        return image
    }

    private func saveImageToDisk(image: CIImage, name: String) {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            print("failed to get colorSpace")
            return
        }
        let strippedName = name.replacingOccurrences(of: " ", with: "")
        let path = path.appendingPathComponent(saveFilePath, isDirectory: true).appendingPathComponent(strippedName).appendingPathExtension("jpg")
        let context = CIContext()

        do {
            try context.writeJPEGRepresentation(of: image, to: path, colorSpace: colorSpace)
        } catch {
            print("error writing as jpg", error)
        }
    }

}
