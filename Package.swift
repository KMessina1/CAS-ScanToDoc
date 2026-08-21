// swift-tools-version: 6.2
/*-------------------------------------------------------------------------------------------------------------------------
     File: Package.swift
   Author: Kevin Messina
  Created: 8/21/26
 Modified: 08/21/2026 05:51 PM EDT
  Version: 1
   Source: CODEX: (GPT-5) 🤖AI Code a portion or all of this code.

©2026 Creative App Solutions, LLC. - All Rights Reserved.
--------------------------------------------------------------------------------------------------------------------------
NOTES:
-------------------------------------------------------------------------------------------------------------------------*/

import PackageDescription

let package = Package(
    name: "CAS-ScanToDoc",
    platforms: [
        .iOS(.v26),
        .macCatalyst(.v26)
    ],
    products: [
        .library(
            name: "CASScanToDoc",
            targets: ["CASScanToDoc"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/KMessina1/CAS-External-Foundations.git",
            from: "1.1.4"
        )
    ],
    targets: [
        .target(
            name: "CASScanToDoc",
            dependencies: [
                .product(
                    name: "CASExternalFoundations",
                    package: "CAS-External-Foundations"
                )
            ]
        ),
        .testTarget(
            name: "CASScanToDocTests",
            dependencies: ["CASScanToDoc"]
        )
    ],
    swiftLanguageModes: [.v5]
)
