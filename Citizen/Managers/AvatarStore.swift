//
//  AvatarStore.swift
//  Citizen
//
//  Created by GE-Developer
//

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

@MainActor
@Observable
final class AvatarStore {
    private(set) var avatar: CGImage?
    
    static let shared = AvatarStore()
    
    nonisolated private static let maxPixelSize = 300
    
    private init() {
        avatar = Self.readFromDisk()
    }
    
    func save(_ data: Data) async -> Data? {
        guard let jpeg = await Task.detached(priority: .userInitiated, operation: {
            Self.downscaledJPEG(from: data)
        }).value else { return nil }
        
        guard writeToDisk(jpeg) else { return nil }
        
        avatar = Self.image(from: jpeg)
        return jpeg
    }
    
    func store(_ jpeg: Data) {
        guard writeToDisk(jpeg) else { return }
        avatar = Self.image(from: jpeg)
    }
    
    func currentJPEGData() -> Data? {
        try? Data(contentsOf: Self.fileURL)
    }
    
    func wipe() {
        try? FileManager.default.removeItem(at: Self.fileURL)
        avatar = nil
    }
    
    private func writeToDisk(_ jpeg: Data) -> Bool {
        let url = Self.fileURL
        
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try jpeg.write(to: url, options: .atomic)
            return true
        } catch {
            print("[AvatarStore] failed to write avatar: \(error)")
            return false
        }
    }
    
    nonisolated private static var fileURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatar.jpg")
    }
    
    nonisolated private static func downscaledJPEG(from data: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(
            source, 0,
            options as CFDictionary) else { return nil }
        
        let output = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(
            output,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else { return nil }
        
        CGImageDestinationAddImage(
            destination,
            thumbnail,
            [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary
        )
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
    
    nonisolated private static func readFromDisk() -> CGImage? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return image(from: data)
    }
    
    nonisolated private static func image(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}
