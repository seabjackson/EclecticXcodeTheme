//
//  FiraCodeAsset.swift
//  EclecticTheme
//
//  Created by Seab on 9/14/24.
//

import Foundation

protocol FetchFont {
    func fetchFont() async throws
}

@available(macOS 12.0, *)
struct FiraCodeFont: FetchFont {
    func fetchFont() async throws {
        let downloadURL = try await fetchLatestFiraCodeFontReleaseURL()
        print("the download url is: \(downloadURL)")
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

}

struct FiraCodeAsset: Codable {
    let browserDownloadUrl: String
}

struct Release: Codable {
    let tagName: String
    let assets: [FiraCodeAsset]
}
