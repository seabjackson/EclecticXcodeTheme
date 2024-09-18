//
//  FiraFontDownloader.swift
//  EclecticTheme
//
//  Created by Seab on 9/17/24.
//

import Foundation
import ZIPFoundation
import CoreText

@available(macOS 12.0, *)
struct FiraCodeFont: FetchFont {
    func fetchFont() async throws {
        let downloadURL = try await fetchLatestFiraCodeFontReleaseURL()
        try await downloadAndExtractZippedFile(from: downloadURL)
    }
    
    // Fetch latest FiraCode font release URL
    private func fetchLatestFiraCodeFontReleaseURL() async throws -> URL {
        guard let latestURL = URL(string: Constants.FiraCodeLatestRelease) else {
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
        
        
        guard let archive = try Archive(url: tempZipURL, accessMode: .read, preferredEncoding: .utf8) else {
            throw FetchFontErrors.zipExtractionFailed
        }
        
        // collect font file urls for registration
        var fontFileURLs: [URL] = []
        
        for entry in archive {
            // only interested in .ttf files
            if entry.path.hasSuffix(".ttf") {
                let fileName = URL(fileURLWithPath: entry.path).lastPathComponent
                let destinationURL = fontsFolderURL.appending(path: fileName, directoryHint: .isDirectory)
                
                _ = try archive.extract(entry, to: destinationURL)
                print("Extracted \(fileName) to \(destinationURL.path)")
                
                fontFileURLs.append(destinationURL)
            }
        }
        
        try registerFonts(at: fontFileURLs)
        
        try fileManager.removeItem(at: tempZipURL)
        print(" Congrats FiraCode successfully installed")
    }
    
    func registerFonts(at urls: [URL]) throws {
        for url in urls {
            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(url as CFURL, .user, &error)
            if !success {
                if let error = error?.takeRetainedValue() {
                    throw error as Error
                } else {
                    throw NSError(domain: "FontRegistration", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error registering font at \(url)"])
                }
            }
        }
    }
    
    struct Constants {
        static let FiraCodeLatestRelease: String = "https://api.github.com/repos/tonsky/FiraCode/releases/latest"
    }

}

class FontDownloader {
    let fontFetcher: FetchFont
    
    init(fontFetcher: FetchFont) {
        self.fontFetcher = fontFetcher
    }
    
    func downloadFont() async throws {
        do {
            try await fontFetcher.fetchFont()
        } catch {
            throw FetchFontErrors.downloadFontFailed
        }
    }
}
