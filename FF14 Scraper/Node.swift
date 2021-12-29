//
//  Node.swift
//  FF14 Scraper
//
//  Created by Christopher Devito on 12/8/21.
//

import Foundation

protocol Node: Codable {
    var name: String { get }
    var time: Int? { get }
    var location: String { get }
    var img: String { get }
    var description: String { get }
    var type: String { get }
    var source: String { get }
    var lvl: Int { get }
    var stars: Int { get }
    var x: Int { get }
    var y: Int { get }
    var expac: Int { get }
    var gathering: Int { get }
}

enum Profession: String {
    case botany
    case mining
    case fishing
}

enum locations: String, Codable {
    case llud = "Limsa Lominsa Upper Decks"
    case llld = "Limsa Lominsa Lower Decks"
    case eln = "Eastern La Noscea"
    case lln = "Lower La Noscea"
    case mln = "Middle La Noscea"
    case uln = "Upper La Noscea"
    case wln = "Western La Noscea"
    case oln = "Outer La Noscea"
    case ng = "New Gridania"
    case og = "Old Gridania"
    case cs = "Central Shroud"
    case es = "East Shroud"
    case ns = "North Shroud"
    case ss = "South Shroud"
    case ct = "Central Thanalan"
    case et = "Eastern Thanalan"
    case nt = "Northern Thanalan"
    case st = "Southern Thanalan"
    case wt = "Western Thanalan"
    case tlb = "The Lavender Beds"
    case cch = "Coerthas Central Highlands"
    case cwh = "Coerthas Western Highlands"
    case md = "Mor Dhona"
    case mist = "Mists"
    case lb = "Labender Beds"
}
