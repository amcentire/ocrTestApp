//
//  ResultsViewController.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 9/30/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit
import CoreData

class ResultsViewController: UIViewController {
    
    var passedResult: Results?
    

    @IBOutlet weak var tableView: UITableView!
    
    private var diffableDataSource: UITableViewDiffableDataSource<Int, Results>!
    private var snapshot = NSDiffableDataSourceSnapshot<Int, Results>()
    
    public var resultsArray = [Results]() {
        didSet {
            self.resultsArray.reverse()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultsTableViewCell")

        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 500
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
    }
    
    func getData() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TestResults")
        do {
            let result = try managedContext?.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                
                let scanTypeString = data.value(forKey: "scanType") as? String
                let cameraTypeString = data.value(forKey: "cameraType") as? String
                let image = data.value(forKey: "image") as? Data
                let results = Results(scanType: nil, cameraType: nil, scanTypeString: scanTypeString, cameraTypeString: cameraTypeString, notesOnCurrentTest: data.value(forKey: "notes") as? String, image: image, identifier: data.value(forKey: "identifier") as! NSUUID, timeStamp: data.value(forKey: "timeStamp") as? String, createdByUser: data.value(forKey: "createdByUser") as? String,  returnedText: data.value(forKey: "returnedText") as? String)
                if image != nil {
                    self.resultsArray.append(results)
                }
                else {
                    print("Image data is nil \(image)")
                }
                
            }
                
            }
            catch {
                
            }
       
        
    }


}

extension ResultsViewController: UITableViewDelegate {
    
}

extension ResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ResultsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell", for: indexPath) as! ResultsTableViewCell
        
        let scanType = self.resultsArray[indexPath.row].scanTypeString ?? "nil"
        let cameraType = self.resultsArray[indexPath.row].cameraTypeString ?? "nil"
        let notes = self.resultsArray[indexPath.row].notesOnCurrentTest ?? "nil"
        let user = self.resultsArray[indexPath.row].createdByUser ?? "nil"
        let timeStamp = self.resultsArray[indexPath.row].timeStamp ?? "nil"
        let returnedText = self.resultsArray[indexPath.row].returnedText ?? "nil"
        let image = self.resultsArray[indexPath.row].image

        cell.resultsImageView.image = UIImage(data: image!)
        cell.resultsLabel.text = "OCR result: \(returnedText)\nCamera Type: \(cameraType) | ScanType: \(scanType)\nNotes: \(notes)\nTime: \(timeStamp) "
//
        
        return cell
    }
    
    
}
