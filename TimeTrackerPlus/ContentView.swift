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
    @State private var projects = ["Project A", "Project B"] // Flexible project list
    @State private var isTracking = false
    @State private var startTime: Date?
    @State private var timeRecords: [(project: String, start: Date, end: Date)] = []
    @State private var statusMessage = "Not Tracking" // Status message
    @State private var showingFilePicker = false
    @State private var temporaryFileURL: URL?

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
                createTemporaryFile()
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
            .sheet(isPresented: $showingFilePicker) {
                if let temporaryFileURL = temporaryFileURL {
                    FilePicker(url: temporaryFileURL) { url in
                        print("File saved to: \(url.absoluteString)")
                    }
                }
            }

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

    func createTemporaryFile() {
        let csvString = timeRecords.map {
            "\"\($0.project)\",\"\($0.start)\",\"\($0.end)\""
        }.joined(separator: "\n")

        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent("TimeRecords.csv")

        do {
            try csvString.write(to: temporaryFileURL, atomically: true, encoding: .utf8)
            self.temporaryFileURL = temporaryFileURL
            self.showingFilePicker = true
        } catch {
            print("Error creating temporary file: \(error)")
        }
    }
}
