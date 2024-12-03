//
//  main.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

// MARK: - Scraper Objects
// General Scrapers
//let folkloreNodesScraper = FolkloreNodesScraper() // updated 12-01-2024
//let ephermeralNodesScraper = EphemeralNodesScraper() // updated 12-01-2024
//let unspoiledNodesScraper = UnspoiledNodesScraper() // updated 12-01-2024
//let collectiblesScraper = CollectablesScraper() // updated 12-01-2024
//let normalNodesScraper = NormalNodesScraper() // updated 12-02-2024
//let gatheringNodeScraper = GatheringNodeScraper() // updated 12-02-2024

// Fishing Scrapers
let fishingNodeScraper = FishingNodeScraper()
//let addWeatherChain = AddWeatherChain() // updated 11-26-2024

// Misc scrapers
//let removeDuplicates = RemoveDuplicates() // updated 11-26-2024
//let fetchImagesScraper = FetchImagesScraper() // updated 11-23-2024
//let updateExpac = UpdateExpac() // updated 11-23-2024
//let updateName = UpdateName() // updated 11-23-2024
//let updateFishingDescript = UpdateFishingDescription() // updated 11-26-2024


// MARK: - Scraper calls
// Uncomment call to run that scraper
//try folkloreNodesScraper.scrapeFolkloreNodesWiki()
//try ephermeralNodesScraper.scrapeEphemeralNodesWiki()
//try unspoiledNodesScraper.scrapeUnspoiledNodesWiki()
//try collectiblesScraper.scrapeCollectiblesWiki()
//try normalNodesScraper.scrapeNormalNodesWiki()

//try gatheringNodeScraper.scrapeGatheringNodesWiki()
try fishingNodeScraper.scrapeGatheringNodesWiki()

//fetchImagesScraper.fetchAllImages()
//try updateExpac.fixExpacData()
//try updateName.fixNames()
//try updateFishingDescript.fixFishDesc()
//try removeDuplicates.fixDuplicates()
//try addWeatherChain.fixWeather()
