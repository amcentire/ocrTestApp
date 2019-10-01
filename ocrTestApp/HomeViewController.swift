//
//  HomeViewController.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 9/29/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentConfigurationLabel: UILabel!
    
    @IBOutlet weak var containerScanButton: UIButton!
    @IBOutlet weak var sealScanButton: UIButton!
    
    @IBOutlet weak var tareWeightButton: UIButton!
    
    @IBOutlet weak var cameraScanButton: UIButton!
    
    @IBOutlet weak var cameraAVButton: UIButton!
    
    
    @IBOutlet weak var notesTextField: UITextField!
    
    @IBOutlet weak var mainView: UIView!
    
    
    private var currentResult: Results = Results(scanType: nil, cameraType: nil, notesOnCurrentTest: "", image: nil, identifier: NSUUID()) {
        didSet {
            self.loadView()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func containerButtonTapped(_ sender: Any) {
        self.currentResult.scanType = .containerCode
        updateLabel()
    }
    
    @IBAction func sealButtonTapped(_ sender: Any) {
        self.currentResult.scanType = .sealCode
        updateLabel()
    }
    
    @IBAction func tareWeightTapped(_ sender: Any) {
        self.currentResult.scanType = .tareWeight
        updateLabel()
    }
    
    @IBAction func scanButtonTapped(_ sender: Any) {
        self.currentResult.cameraType = .scan
        updateLabel()
    }
    
    @IBAction func avButtonTapped(_ sender: Any) {
        self.currentResult.cameraType = .av
        updateLabel()
    }
    
    @IBAction func runThisTestTapped(_ sender: Any) {
        updateLabel()
        self.createDatabaseObject()
    }
    
    @IBAction func viewResultsTapped(_ sender: Any) {
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateLabel()
        return true
    }
    
    private func updateLabel() {
        guard let scanTypeLabel = self.currentResult.scanType else { return }
        guard let cameraTypeLabel = self.currentResult.cameraType else { return }
        let currentUserLabel = self.currentResult.getCurrentUser()
        let timeStamp = self.currentResult.generateCurrentTimeStamp()
        
        guard let notes = self.notesTextField.text else { return }
        self.currentResult.notesOnCurrentTest = notesTextField.text
        currentConfigurationLabel.text = "CURRENT CONFIGURATION:\nScan Type: \(scanTypeLabel)\nCamera Type: \(cameraTypeLabel)\nNotes on Current Test: \(notes)\nCreated By: \(currentUserLabel) at \(timeStamp)"
        
    }
    
    private func createDatabaseObject() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let testResultsEntity = NSEntityDescription.entity(forEntityName: "TestResults", in: managedContext) else { return }
               
        let testResults = NSManagedObject(entity: testResultsEntity, insertInto: managedContext)
        testResults.setValue(self.currentResult.scanType?.updateTitle(), forKey: "scanType")
        testResults.setValue(self.currentResult.cameraType?.updateTitle(), forKey: "cameraType")
        testResults.setValue(self.currentResult.getCurrentUser(), forKey: "createdByUser")
        testResults.setValue(self.currentResult.generateCurrentTimeStamp(), forKey: "timeStamp")
        testResults.setValue(self.currentResult.identifier, forKey: "identifier")
        testResults.setValue(self.currentResult.notesOnCurrentTest, forKey: "notes")
        
        do {
            try managedContext.save()
            }
            catch {
                print("Error")
            }
               
    }

}
