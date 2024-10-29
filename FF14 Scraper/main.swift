//
//  main.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

// MARK: - Scraper Objects
// Botany Scrapers
//let botanyNodesScraper = BotanyNodesScraper() // updated 10-28-2024
//let botanyNodesFolkloreScraper = BotanyNodeFolkloreScraper() // updated 10-28-2024
//let botanyNodesUnspoiledScraper = BotanyNodeUnspoiledScraper() // working 10-28-2024
//let botanynodesEphermeralScraper = BotanyEphemeralNodesScraper() // updated 10-28-2024
//let botanyNodeScraper = BotanyNodeScraper() // updated 10-28-2024

// Mining Scrapers
let miningNodesScraper = MiningNodesScraper()
//let miningNodesFolkloreScraper = MiningNodeFolkloreScraper()
//let miningNodeUnspoiledScraper = MiningNodeUnspoiledScraper()
//let miningNodeScraper = MiningNodeScraper()
//let miningNodesEphemeralScraper = MiningEphemeralNodesScraper()

// Fishing Scrapers
//let fishingNodesScraper = FishingNodesScraper()
//let fishingNodesFolkloreScraper = FishingNodeFolkloreScraper()
//let fishingCollectiblesScraper = FishingCollectiblesScraper()
//let fishingNodeScraper = FishingNodeScraper()
//let addWeatherChain = AddWeatherChain()

// Misc scrapers
//let removeDuplicates = RemoveDuplicates()
//let fetchImagesScraper = FetchImagesScraper()
//let updateExpac = UpdateExpac()
//let updateName = UpdateName()
//let updateFishingDescript = UpdateFishingDescription()


// MARK: - Scraper calls
// Uncomment call to run that scraper
//try botanyNodesScraper.scrapeBotanyNodesWiki()
//try botanyNodesFolkloreScraper.scrapeBotanyNodesWiki()
//try botanyNodesUnspoiledScraper.scrapeBotanyNodesWiki()
//try botanynodesEphermeralScraper.scrapeBotanyNodesWiki()
//try botanyNodeScraper.scrapeGatheringNodesWiki()
try miningNodesScraper.scrapeMiningNodesWiki()
//try miningNodesFolkloreScraper.scrapeMiningNodesWiki()
//try miningNodeUnspoiledScraper.scrapeMiningNodesWiki()
//try miningNodesEphemeralScraper.scrapeMiningNodesWiki()
//try miningNodeScraper.scrapeGatheringNodesWiki()
//try fishingNodesFolkloreScraper.scrapeFishingNodesWiki()
//try fishingNodesScraper.scrapeFishingNodesWiki()
//try fishingCollectiblesScraper.scrapeFishingCollectiblesWiki()
//try fishingNodeScraper.scrapeGatheringNodesWiki()
//fetchImagesScraper.fetchFromJSONFile()
//try updateExpac.fixExpacData()
//try updateName.fixExpacData()
//try updateFishingDescript.fixFishDesc()
//try removeDuplicates.fixDuplicates()
//try addWeatherChain.fixWeather()
