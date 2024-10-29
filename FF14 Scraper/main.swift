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
//let botanyNodeScraper = BotanyNodeScraper() // updated 10-28-2024
let botanyNodesFolkloreScraper = BotanyNodeFolkloreScraper()
//let botanyNodesUnspoiledScraper = BotanyNodeUnspoiledScraper()
//let botanynodesEphermeralScraper = EphemeralNodesScraper()

// Mining Scrapers
//let miningNodesScraper = MiningNodesScraper()
//let miningNodeScraper = MiningNodeScraper()
//let miningNodesFolkloreScraper = MiningNodeFolkloreScraper()
//let miningNodeUnspoiledScraper = MiningNodeUnspoiledScraper()

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
//try botanyNodeScraper.scrapeGatheringNodesWiki()
try botanyNodesFolkloreScraper.scrapeBotanyNodesWiki()
//try botanyNodesUnspoiledScraper.scrapeBotanyNodesWiki()
//try botanynodesEphermeralScraper.scrapeBotanyNodesWiki()
//try miningNodesFolkloreScraper.scrapeMiningNodesWiki()
//try fishingNodesFolkloreScraper.scrapeFishingNodesWiki()
//try miningNodeUnspoiledScraper.scrapeMiningNodesWiki()
//try miningNodesScraper.scrapeMiningNodesWiki()
//try fishingNodesScraper.scrapeFishingNodesWiki()
//try fishingCollectiblesScraper.scrapeFishingCollectiblesWiki()
//try miningNodeScraper.scrapeGatheringNodesWiki()
//try fishingNodeScraper.scrapeGatheringNodesWiki()
//fetchImagesScraper.fetchFromJSONFile()
//try updateExpac.fixExpacData()
//try updateName.fixExpacData()
//try updateFishingDescript.fixFishDesc()
//try removeDuplicates.fixDuplicates()
//try addWeatherChain.fixWeather()
