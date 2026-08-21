/*-------------------------------------------------------------------------------------------------------------------------
     File: Camera_ScanToDocFunctions.swift
   Author: Kevin Messina
  Created: 6/29/24
 Modified: 08/21/2026 05:51 PM EDT
  Version: 3
   Source: CODEX: (GPT-5) 🤖AI Code a portion or all of this code.
 
©2026 Creative App Solutions, LLC. - All Rights Reserved.
--------------------------------------------------------------------------------------------------------------------------
NOTES:
-------------------------------------------------------------------------------------------------------------------------*/

import SwiftUI
import UIKit
import VisionKit

public enum ScannedDocItemTypes: String {
    case none = "--"
    case receipt = "Reciept"
    case purchase = "Purchase Related"
    case target = "Target"
    case sale = "Sale Related"
    case insurance = "Insurance Policy"
    case certificate = "Certificate"
    case title = "Title/Ownership"
    case application = "Application/Registration"
    case documentation = "Documentation"
    case manual = "Manual/Guide"
    case other = "Other"

    public static let arr: [String] = [
        none.rawValue,
        application.rawValue,
        certificate.rawValue,
        documentation.rawValue,
        manual.rawValue,
        insurance.rawValue,
        purchase.rawValue,
        receipt.rawValue,
        sale.rawValue,
        target.rawValue,
        title.rawValue,
        other.rawValue
    ]
}

public enum ScannedPicItemTypes: String {
    case none = "--"
    case item = "Item: Photo of Item"
    case manual = "Item: Manual/Guide"
    case driverLicense = "ID: Driver License"
    case stateID = "ID: State ID"
    case militaryID = "ID: Military ID"
    case membership = "ID: Membership ID"
    case permit = "ID: Permit/License"
    case certification = "ID: Certification"
    case target = "Range: Target"
    case rangeCard = "Range: Serssion Card"
    case other = "Other"

    public static let arr: [String] = [
        none.rawValue,
        item.rawValue,
        manual.rawValue,
        certification.rawValue,
        driverLicense.rawValue,
        militaryID.rawValue,
        membership.rawValue,
        permit.rawValue,
        stateID.rawValue,
        target.rawValue,
        rangeCard.rawValue,
        other.rawValue
    ]
}

public enum ScannedItemType: String {
    case photo = "Photo"
    case document = "Document"

    public static let arr: [String] = [
        document.rawValue,
        photo.rawValue
    ]
}

public struct VNDocumentCameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding private var scanResult: [UIImage]

    public init(scanResult: Binding<[UIImage]>) {
        _scanResult = scanResult
    }

    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }

    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(scanResult: $scanResult)
    }

    public final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding private var scanResult: [UIImage]

        init(scanResult: Binding<[UIImage]>) {
            _scanResult = scanResult
        }

        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            controller.dismiss(animated: true)
            let newImages = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
            scanResult.append(contentsOf: newImages)
        }

        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            print("Document scanner error: \(error.localizedDescription)")
            controller.dismiss(animated: true)
        }
    }
}

extension UIImage {
    public func resize(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
