# FF14-Scraper

A web scraper writen in Swift

## Description

FF14-Scraper is a web scraper that uses SwiftSoup to get the HTML from consolegames and gamerescape wikis to get the data for gathering items for the game Final Fantasy XIV. Converts scraped data into a JSON file for use in the EorzeaTimers App. 

## Getting Started

### Dependencies

* This project requires Xcode and macOS. 
* This project uses SwiftSoup via Swift Package Manager which will not require any additional installation

### Installing

* Install this project by cloning or downloading zip file from github.com/DeVitoC/FF14-Scraper

### Executing program

* Open with Xcode 
* In main.swift, uncomment lines 29-41 as needed to run the individual scraper functions 
* Must have at least run the methods in lines 29-38 with the same gathering type (Botany, Mining, Fishing) as the method in lines 39-41 you have selected
* Scrapers have a 2 second delay between items to respect target site's bandwidth traffic, so please allow adequate time to finish running

## Help

If you have any questions or need additional help with running this project, email me here

## Authors

Contributors names and contact info

Christopher DeVito 
[email: christopher.devito@protonmail.com](christopher.devito@protonmail.com)

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

Scraping Libray with documentation.
* [SwiftSoup](https://github.com/scinfu/SwiftSoup)
