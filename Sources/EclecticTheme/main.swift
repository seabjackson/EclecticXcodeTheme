// The Swift Programming Language
// https://docs.swift.org/swift-book

print("Hello, world!")

import Foundation

let fontDownloader = FontDownloader(fontFetcher: FiraCodeFont())
await fontDownloader.downloadFont()
try installXcodeTheme("Eclectic")

enum ThemeInstallationError: Error {
    case themeNotFound
}

func installXcodeTheme(_ themeName: String) throws {
    let fileManager = FileManager.default
    let homeDirectory = fileManager.homeDirectoryForCurrentUser
    let xcodeThemeFolder = homeDirectory
        .appendingPathComponent("Library")
        .appendingPathComponent("Developer")
        .appendingPathComponent("Xcode")
        .appendingPathComponent("UserData")
        .appendingPathComponent("FontAndColorThemes")
    
    if !fileManager.fileExists(atPath: xcodeThemeFolder.path) {
        try fileManager.createDirectory(at: xcodeThemeFolder, withIntermediateDirectories: true)
    }
    
    let themeFileName = "\(themeName).xccolortheme"
    guard let themeFileURL = Bundle.module.url(forResource: themeName, withExtension: "xccolortheme") else {
        throw ThemeInstallationError.themeNotFound
    }
    let destinationURL = xcodeThemeFolder.appendingPathComponent(themeFileName)
    if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
    }
    try fileManager.copyItem(at: themeFileURL, to: destinationURL)
    print("You're all set! Xcode theme \(themeName) has been successfully installed")
}
