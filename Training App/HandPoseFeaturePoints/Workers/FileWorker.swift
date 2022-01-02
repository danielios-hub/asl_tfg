//
//  FileManager.swift
//  HandPoseFeaturePoints
//
//  Created by Daniel Gallego Peralta on 2/3/21.
//

import Foundation
import ZIPFoundation

public extension FileManager {
    static var documentsDirectoryURL: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

public protocol FileWorkerProtocol {
    func saveTrainingData(for label: LabelClass, data: [[Double]], header: String)
    func cleanData()
    func existsTrainingResults() -> Bool
}

public class FileWorker: FileWorkerProtocol {
    
    static var sharedInstance = FileWorker()
    
    var folderName = "train"
    
    var zipName: String {
        return "archive-\(Date.timeIntervalSinceReferenceDate).zip"
    }
    
    var folderTrain: URL {
        return FileManager.documentsDirectoryURL.appendingPathComponent(folderName)
    }
    
    private init() {}
    
    public func cleanData() {
        if FileManager.default.fileExists(atPath: folderTrain.path) {
            do {
                try removeItem(at: folderTrain)
            } catch {
                print("Error cleaning files \(error.localizedDescription)")
            }
        }
    }
    
    public func existsTrainingResults() -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: folderTrain.path, isDirectory: &isDirectory)
    }
    
    public func saveTrainingData(for label: LabelClass, data: [[Double]], header: String) {
        let tag = label.rawValue.uppercased()
        let extensionFile = ".csv"
        
        let folderTrain = FileManager.documentsDirectoryURL.appendingPathComponent(folderName)
        let folderLabel = folderTrain.appendingPathComponent(tag)
        let filePath = folderLabel.appendingPathComponent("\(tag)\(extensionFile)")
        
        do {
            if !FileManager.default.fileExists(atPath: folderLabel.absoluteString) {
                try createLabelDirectory(at: folderLabel)
            }
            
            if FileManager.default.fileExists(atPath: filePath.absoluteString) {
                try removeItem(at: filePath)
            }
            
            
            var textData = "\(header) \n"
            for feature in data {
                let newLine = feature.description.removeArraySeparator() + "\n"
                textData += newLine
            }
            
            try textData.write(to: filePath, atomically: true, encoding: .utf8)
            
        } catch {
            print("error \(error)")
        }
        
    }
    
    private func removeItem(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    private func createFile(at path: String, data: Data) throws {
        FileManager.default.createFile(atPath: path, contents: data)
    }
    
    private func createLabelDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func compressTrainFolder() -> URL? {
        let folderTrain = FileManager.documentsDirectoryURL.appendingPathComponent(folderName)
        
        let destinationPath = FileManager.documentsDirectoryURL.appendingPathComponent(zipName)
        
        do {
            try FileManager.default.zipItem(at: folderTrain, to: destinationPath)
            return destinationPath
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

}
