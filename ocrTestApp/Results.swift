//
//  Results.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 9/30/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//
import Foundation
import UIKit
import CoreData

struct Results: Hashable {
    
    var scanType: ScanType?
    var cameraType: CameraType?
    var scanTypeString: String?
    var cameraTypeString: String?
    var notesOnCurrentTest: String?
    var image: Data?
    var identifier = NSUUID()
    var timeStamp: String?
    var createdByUser: String?
    var returnedText: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
   
    static func ==(lhs: Results, rhs: Results) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func generateCurrentTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    func getCurrentUser() -> String {
        var username: String = ""
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return "" }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                
                username = data.value(forKey: "username") as! String
                
            }
                
            }
            catch {
                
            }
        return username
    }
    
    
    func updateScanType(string: String?) -> ScanType? {
        var scanType: ScanType?
        if string == "Container" {
            scanType = .containerCode
        }
        if string == "SealCode" {
            scanType = .sealCode
        }
        if string == "TareWeight" {
            scanType = .tareWeight
        }
        return scanType
    }
    
    func updateCameraType(string: String?) -> CameraType? {
           var scanType: CameraType?
           if string == "Scan" {
               scanType = .scan
           }
           if string == "AV" {
               scanType = .av
           }
            if string == "GMLKit" {
                scanType = .gmlKit
            }
           return scanType
       }
}



