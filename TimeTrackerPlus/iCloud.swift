//
//  icloud.swift
//  TimeTrackerPlus
//
//  Created by Carsten on 5/31/24.
//

import Foundation

import UIKit

func saveToiCloud(csvString: String) {
    let fileName = "TimeRecords.csv"
    if let documentDirectory = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("File saved to iCloud: \(fileURL)")
        } catch {
            print("Error saving file to iCloud: \(error)")
        }
    } else {
        print("Error: Could not find iCloud Documents directory.")
    }
}

