//
//  ContentView.swift
//  TimeTrackerPlus
//
//  Created by Carsten on 5/31/24.
//
import UIKit
import SwiftUI

struct ContentView: View {
    @State private var selectedProject = "Project A"
    @State private var isTracking = false
    @State private var startTime: Date?
    @State private var timeRecords: [(project: String, start: Date, end: Date)] = []

    var body: some View {
        VStack {
            Spacer()
            Picker("Select Project", selection: $selectedProject) {
                Text("Project A").tag("Project A")
                Text("Project B").tag("Project B")
                // Add more projects here
            }
            .pickerStyle(WheelPickerStyle())
            .font(.title) // Adjust text size
            .padding()
            Spacer()
            HStack {
                Button(action: {
                    startTracking()
                }) {
                    Image("startButton") // Use the start button image
                        .resizable()
                        .frame(width: 100, height: 50)
                        .overlay(
                            Text("Start")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                }
                .disabled(isTracking)
                .padding(.horizontal)

                Button(action: {
                    stopTracking()
                }) {
                    Image("stopButton") // Use the stop button image
                        .resizable()
                        .frame(width: 100, height: 50)
                        .overlay(
                            Text("Stop")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                }
                .disabled(!isTracking)
                .padding(.horizontal)
            }
            .padding()

            Spacer().frame(height: 50)

            Button(action: {
                exportCSV()
            }) {
                Image("exportButton") // Use the export button image
                    .resizable()
                    .frame(width: 100, height: 50)
                    .overlay(
                        Text("Export")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    func startTracking() {
        startTime = Date()
        isTracking = true
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.startBackgroundTask()
        }
    }

    func stopTracking() {
        if let start = startTime {
            let end = Date()
            timeRecords.append((project: selectedProject, start: start, end: end))
        }
        isTracking = false
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.endBackgroundTask()
        }
    }

    func exportCSV() {
        let csvString = timeRecords.map {
            "\"\($0.project)\",\"\($0.start)\",\"\($0.end)\""
        }.joined(separator: "\n")
        saveToICloud(csvString: csvString)
    }

    func saveToICloud(csvString: String) {
        let fileName = "TimeRecords.csv"
        let folderName = "TimeTracking"

        // Save to iCloud
        if let iCloudDocumentDirectory = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            let iCloudFolderURL = iCloudDocumentDirectory.appendingPathComponent(folderName)
            createFolderIfNeeded(at: iCloudFolderURL)
            let iCloudFileURL = iCloudFolderURL.appendingPathComponent(fileName)
            saveFile(at: iCloudFileURL, content: csvString)
        }
    }

    func createFolderIfNeeded(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating folder: \(error)")
        }
    }

    func saveFile(at url: URL, content: String) {
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            print("File saved to: \(url)")
        } catch {
            print("Error saving file: \(error)")
        }
    }
}

