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

enum FetchFontErrors: Error {
    case invalidURL
    case downloadFontFailed
    case firaCodeReleaseNotFound
    case zipExtractionFailed
}

struct FiraCodeAsset: Codable {
    let browserDownloadUrl: String
}

struct Release: Codable {
    let tagName: String
    let assets: [FiraCodeAsset]
}


