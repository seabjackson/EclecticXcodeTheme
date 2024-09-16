//
//  FiraCodeAsset.swift
//  EclecticTheme
//
//  Created by Seab on 9/14/24.
//

import Foundation
import ZIPFoundation

protocol FetchFont {
    func fetchFont() async throws
}

@available(macOS 12.0, *)
struct FiraCodeFont: FetchFont {
    func fetchFont() async throws {
        let downloadURL = try await fetchLatestFiraCodeFontReleaseURL()
        print("the download url is: \(downloadURL)")
        do {
            try await downloadAndExtractZippedFile(from: downloadURL)
        }
    }
    
    // Fetch latest FiraCode font release URL
    private func fetchLatestFiraCodeFontReleaseURL() async throws -> URL {
        guard let latestURL = URL(string: "https://api.github.com/repos/tonsky/FiraCode/releases/latest") else {
            throw FetchFontErrors.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: latestURL)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let release = try jsonDecoder.decode(Release.self, from: data)
        guard let asset = release.assets.first,
              let downloadURL = URL(string: asset.browserDownloadUrl) else {
            throw FetchFontErrors.firaCodeReleaseNotFound
        }
        return downloadURL
    }
    
    // download and extract zipped file to install fonts
    @available(macOS 13.0, *)
    func  downloadAndExtractZippedFile(from url: URL) async throws {
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let fontsFolderURL = homeDirectory.appendingPathComponent("Library/Fonts")
        let tempDirectory = fileManager.temporaryDirectory
        
        /// check if FiraCode is already installed
        if fileManager.fileExists(atPath: fontsFolderURL.appending(path: "FiraCode-Regular.ttf", directoryHint: .isDirectory).path) {
            print("✅ FiraCode is already installed.")
            return
        }
        
        print(" Downloading FiraCode font ...")
        let (fontZipData, _) = try await URLSession.shared.data(from: url)
        let tempZipURL = tempDirectory.appending(path: "FiraCode.zip", directoryHint: .isDirectory)
        try fontZipData.write(to: tempZipURL)
        print("📦 Extracting FiraCode font...")
        
        
        guard let archive = try Archive(url: tempZipURL, accessMode: .read) else {
            throw FetchFontErrors.zipExtractionFailed
        }
        
        for entry in archive {
            // only interested in .ttf files
            if entry.path.hasSuffix(".ttf") {
                let fileName = URL(fileURLWithPath: entry.path).lastPathComponent
                let destinationURL = fontsFolderURL.appending(path: fileName, directoryHint: .isDirectory)
                
                _ = try archive.extract(entry, to: destinationURL)
                print("Extracted \(fileName) to \(destinationURL.path)")
            }
        }
        try fileManager.removeItem(at: tempZipURL)
        print(" Congrats FiraCode successfully installed")
    }

}

struct FiraCodeAsset: Codable {
    let browserDownloadUrl: String
}

struct Release: Codable {
    let tagName: String
    let assets: [FiraCodeAsset]
}
