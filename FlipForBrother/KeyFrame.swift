//
//  KeyFrame.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

struct KeyFrame: Codable {
    var transformableImages: [TransformableImage] = []
    var isKey: Bool = false
    static func save(keyframes: [KeyFrame], to fileName: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(string: documentsPath)!.appendingPathComponent(fileName, isDirectory: false)
        let encoder = JSONEncoder()
        let data = try? encoder.encode(keyframes)
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
    }
    static func load(from fileName: String) -> [KeyFrame] {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(string: documentsPath)!.appendingPathComponent(fileName, isDirectory: false)
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            if let model = try? decoder.decode(
                [KeyFrame].self, from: data) {
                return model
            }
        }
        return []
    }
}
