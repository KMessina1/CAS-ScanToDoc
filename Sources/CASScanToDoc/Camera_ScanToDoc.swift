/*-------------------------------------------------------------------------------------------------------------------------
     File: Camera_ScanToDoc.swift
   Author: Kevin Messina
  Created: 6/29/24
 Modified: 08/21/2026 05:51 PM EDT
  Version: 5
   Source: CODEX: (GPT-5) 🤖AI Code a portion or all of this code.
 
©2026 Creative App Solutions, LLC. - All Rights Reserved.
--------------------------------------------------------------------------------------------------------------------------
NOTES:
-------------------------------------------------------------------------------------------------------------------------*/

import SwiftUI
import PDFKit
import VisionKit
import CASExternalFoundations

public struct DocScanView: View {
    @Environment(\.dismiss) private var dismiss

    let table: String
    @Binding var scannedImages: [UIImage]
    @Binding var savedImgFilenames: String
    @Binding var allImgs: [UIImage]
    let docTypes: String
    let saveIn: Files.directories
    var bypassSave = false

    @State private var showScan = false

    public init(
        table: String,
        scannedImages: Binding<[UIImage]>,
        savedImgFilenames: Binding<String>,
        allImgs: Binding<[UIImage]>,
        docTypes: String,
        saveIn: Files.directories,
        bypassSave: Bool = false
    ) {
        self.table = table
        self._scannedImages = scannedImages
        self._savedImgFilenames = savedImgFilenames
        self._allImgs = allImgs
        self.docTypes = docTypes
        self.saveIn = saveIn
        self.bypassSave = bypassSave
    }

    private var scannerAvailable: Bool {
        VNDocumentCameraViewController.isSupported
    }

    public var body: some View {
        NavigationStack {
            Group {
                if !scannerAvailable {
                    ContentUnavailableView(
                        "Scanner Unavailable",
                        systemImage: "camera.fill",
                        description: Text("Camera services are not available on this device.")
                    )
                } else if scannedImages.isEmpty {
                    ContentUnavailableView(
                        "No Scanned Items",
                        systemImage: "doc.viewfinder",
                        description: Text("Tap Scan to add a document or photo.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(scannedImages.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Document Scanner")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Scan", systemImage: "doc.viewfinder") { showScan = true }
                        .disabled(!scannerAvailable)
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Clear", systemImage: "trash", role: .destructive) {
                        scannedImages.removeAll()
                        savedImgFilenames = ""
                    }
                    .disabled(scannedImages.isEmpty)

                    Spacer()

                    if docTypes == "images" || docTypes == "all" {
                        Button("Save Photos", systemImage: "photo.on.rectangle") {
                            saveImages()
                        }
                        .disabled(scannedImages.isEmpty)
                    }

                    if docTypes == "pdfs" || docTypes == "all" {
                        Button("Save PDF", systemImage: "doc.text") {
                            savePDF()
                        }
                        .disabled(scannedImages.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showScan) {
                VNDocumentCameraViewControllerRepresentable(scanResult: $scannedImages)
                    .ignoresSafeArea()
            }
        }
        .task { scannedImages = [] }
    }

    private func saveImages() {
        for image in scannedImages {
            let filename = makeFilename(extension: "jpg")

            if !bypassSave {
                let url = Files().returnPathForFilename(filename, in: saveIn).url
                try? image.jpegData(compressionQuality: 1)?.write(to: url, options: .atomic)
            }

            appendFilename(filename)
        }

        allImgs.append(contentsOf: scannedImages)
        dismiss()
    }

    private func savePDF() {
        let document = PDFDocument()

        for (index, image) in scannedImages.enumerated() {
            if let page = PDFPage(image: image) {
                document.insert(page, at: index)
            }
        }

        let filename = makeFilename(extension: "pdf")

        if !bypassSave {
            let url = Files().returnPathForFilename(filename, in: saveIn).url
            try? document.dataRepresentation()?.write(to: url, options: .atomic)
        }

        appendFilename(filename)
        if let firstImage = scannedImages.first {
            allImgs.append(firstImage)
        }
        dismiss()
    }

    private func appendFilename(_ filename: String) {
        savedImgFilenames.append(savedImgFilenames.isEmpty ? filename : ",\(filename)")
    }

    private func makeFilename(extension fileExtension: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss-SSS"
        return "\(formatter.string(from: Date()))-\(tableSuffix).\(fileExtension)"
    }

    private var tableSuffix: String {
        table
    }
}
