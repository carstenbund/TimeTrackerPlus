//
//  ContentView.swift
//  TimeTrackerPlus
//
//  Created by Carsten on 5/31/24.
//
import UIKit
import SwiftUI

struct ContentView: View {
    @State private var selectedProject = "Ophtecs"
    @State private var projects = ["AI Projects", "Ophtecs", "Web Work", "AWS Clients", "S.Gabler", "WP Padel"] // Flexible project list
    @State private var isTracking = false
    @State private var startTime: Date?
    @State private var timeRecords: [(project: String, start: Date, end: Date)] = []
    @State private var statusMessage = "Not Tracking" // Status message

    var body: some View {
        VStack {
            Spacer() // Add this spacer to push the content down

            Picker("Select Project", selection: $selectedProject) {
                ForEach(projects, id: \.self) { project in
                    Text(project).tag(project)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .font(.title) // Adjust text size
            .padding()

            Text(statusMessage) // Display status message
                .font(.headline)
                .padding()

            Spacer() // Add a second spacer to push the content further down
            HStack {
                Button(action: {
                    startTracking()
                }) {
                    Image("startButton") // Use the start button image
                        .resizable()
                        .frame(width: 120, height: 80)
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
                        .frame(width: 120, height: 80)
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
        statusMessage = "Tracking time for \(selectedProject)" // Update status message
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
        statusMessage = "Not Tracking" // Update status message
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.endBackgroundTask()
        }
    }

    func exportCSV() {
        let dateFormatter = ISO8601DateFormatter()
        let csvString = timeRecords.map { record in
            let formattedStart = dateFormatter.string(from: record.start)
            let formattedEnd = dateFormatter.string(from: record.end)
            let duration = record.end.timeIntervalSince(record.start)
            
            let hours = Int(duration) / 3600
            let minutes = Int(duration) % 3600 / 60
            let seconds = Int(duration) % 60
            let formattedDuration = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            return "\"\(record.project)\",\"\(formattedStart)\",\"\(formattedEnd)\",\"\(formattedDuration)\""
        }.joined(separator: "\n")
        
        // Adding the header row
        let header = "\"Project\",\"Start\",\"End\",\"Duration (hh:mm:ss)\""
        let csvWithHeader = "\(header)\n\(csvString)"
        
        saveToLocalAndICloud(csvString: csvWithHeader)
        presentDocumentPicker(with: csvWithHeader)
    }
    
    
    func saveToLocalAndICloud(csvString: String) {
        let fileName = "TimeRecords.csv"
        let folderName = "TimeTracking"
        
        // Save locally
        if let localDocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let localFolderURL = localDocumentDirectory.appendingPathComponent(folderName)
            createFolderIfNeeded(at: localFolderURL)
            let localFileURL = localFolderURL.appendingPathComponent(fileName)
            saveFile(at: localFileURL, content: csvString)
        }

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
    
    func presentDocumentPicker(with content: String) {
        guard let data = content.data(using: .utf8) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("TimeRecords.csv")
        
        do {
            try data.write(to: tempURL)
            
            let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(documentPicker, animated: true, completion: nil)
            }
        } catch {
            print("Error creating temporary file: \(error)")
        }
    }
}
