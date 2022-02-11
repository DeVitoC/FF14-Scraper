//
//  main.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation
import SwiftSoup

// MARK: - Scraper Objects
let botanyNodesScraper = BotanyNodesScraper()
let botanyNodesFolkloreScraper = BotanyNodeFolkloreScraper()
let botanyNodesUnspoiledScraper = BotanyNodeUnspoiledScraper()
let botanynodesEphermeralScraper = EphemeralNodesScraper()
let miningNodesFolkloreScraper = MiningNodeFolkloreScraper()
let fishingNodesFolkloreScraper = FishingNodeFolkloreScraper()
let miningNodeUnspoiledScraper = MiningNodeUnspoiledScraper()
let miningNodesScraper = MiningNodesScraper()
let fishingNodesScraper = FishingNodesScraper()
let fishingCollectiblesScraper = FishingCollectiblesScraper()
let botanyNodeScraper = BotanyNodeScraper()
let miningNodeScraper = MiningNodeScraper()
let fishingNodeScraper = FishingNodeScraper()
let fetchImagesScraper = FetchImagesScraper()


// MARK: - Scraper calls
// Uncomment call to run that scraper
//try botanyNodesScraper.scrapeBotanyNodesWiki()
//try botanyNodesFolkloreScraper.scrapeBotanyNodesWiki()
//try botanyNodesUnspoiledScraper.scrapeBotanyNodesWiki()
//try botanynodesEphermeralScraper.scrapeBotanyNodesWiki()
//try miningNodesFolkloreScraper.scrapeMiningNodesWiki()
//try fishingNodesFolkloreScraper.scrapeFishingNodesWiki()
//try miningNodeUnspoiledScraper.scrapeMiningNodesWiki()
//try miningNodesScraper.scrapeMiningNodesWiki()
//try fishingNodesScraper.scrapeFishingNodesWiki()
//try fishingCollectiblesScraper.scrapeFishingCollectiblesWiki()
//try botanyNodeScraper.scrapeGatheringNodesWiki()
//try miningNodeScraper.scrapeGatheringNodesWiki()
//try fishingNodeScraper.scrapeGatheringNodesWiki()
fetchImagesScraper.fetchFromJSONFile()
