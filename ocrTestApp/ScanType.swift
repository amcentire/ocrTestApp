//
//  ScanType.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 9/29/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import Foundation
import CoreData

public enum ScanType {
    case containerCode
    case sealCode
    case tareWeight
    
    func updateTitle() -> String {
        var displayedTitle: String {
            switch self {
            case .containerCode:
                return "Container"
            case .sealCode:
                return "Seal"
            case .tareWeight:
                return "Tare Weight"
            }
        }
        return displayedTitle
    }
}

public enum CameraType {
    case scan
    case av
    case gmlKit
    
    func updateTitle() -> String {
        var displayedTitle: String {
            switch self {
            case .scan:
                return "Scan"
            case .av:
                return "AV"
            case .gmlKit:
                return "GMLKit"
            }
        }
        return displayedTitle
    }
    
}
