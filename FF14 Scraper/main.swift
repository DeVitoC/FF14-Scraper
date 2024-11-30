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
let folkloreNodesScraper = FolkloreNodesScraper() // updated 11-30-2024

// Botany Scrapers
//let botanyNodesScraper = BotanyNodesScraper() // updated 10-28-2024
//let botanyNodesUnspoiledScraper = BotanyNodeUnspoiledScraper() // working 10-28-2024
//let botanynodesEphermeralScraper = BotanyEphemeralNodesScraper() // updated 10-28-2024
//let botanyNodeScraper = BotanyNodeScraper() // updated 10-28-2024

// Mining Scrapers
//let miningNodesScraper = MiningNodesScraper() // updated 10-29-2024
//let miningNodeUnspoiledScraper = MiningNodeUnspoiledScraper()
//let miningNodesEphemeralScraper = MiningEphemeralNodesScraper()
//let miningNodeScraper = MiningNodeScraper()

// Fishing Scrapers
//let fishingNodesScraper = FishingNodesScraper()
//let fishingCollectiblesScraper = FishingCollectiblesScraper()
//let fishingNodeScraper = FishingNodeScraper()
//let addWeatherChain = AddWeatherChain() // updated 11-26-2024

// Misc scrapers
//let removeDuplicates = RemoveDuplicates() // updated 11-26-2024
//let fetchImagesScraper = FetchImagesScraper() // updated 11-23-2024
//let updateExpac = UpdateExpac() // updated 11-23-2024
//let updateName = UpdateName() // updated 11-23-2024
//let updateFishingDescript = UpdateFishingDescription() // updated 11-26-2024


// MARK: - Scraper calls
// Uncomment call to run that scraper
try folkloreNodesScraper.scrapeFolkloreNodesWiki()

//try botanyNodesScraper.scrapeBotanyNodesWiki()
//try botanyNodesUnspoiledScraper.scrapeBotanyNodesWiki()
//try botanynodesEphermeralScraper.scrapeBotanyNodesWiki()
//try botanyNodeScraper.scrapeGatheringNodesWiki()

//try miningNodesScraper.scrapeMiningNodesWiki()
//try miningNodeUnspoiledScraper.scrapeMiningNodesWiki()
//try miningNodesEphemeralScraper.scrapeMiningNodesWiki()
//try miningNodeScraper.scrapeGatheringNodesWiki()

//try fishingNodesScraper.scrapeFishingNodesWiki()
//try fishingCollectiblesScraper.scrapeFishingCollectiblesWiki()
//try fishingNodeScraper.scrapeGatheringNodesWiki()

//fetchImagesScraper.fetchAllImages()
//try updateExpac.fixExpacData()
//try updateName.fixNames()
//try updateFishingDescript.fixFishDesc()
//try removeDuplicates.fixDuplicates()
//try addWeatherChain.fixWeather()
