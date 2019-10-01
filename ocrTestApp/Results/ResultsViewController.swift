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
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "ResultsTableViewCell")
//        diffableDataSource = UITableViewDiffableDataSource<Int, Results>(tableView: tableView) { (tableView:UITableView, indexPath:IndexPath, model: Results) -> ResultsTableViewCell? in
//            let cell: ResultsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell", for: indexPath) as! ResultsTableViewCell
//            guard let scanType = model.scanType else { return nil }
//            guard let cameraType = model.cameraType else { return nil }
//            guard let notes = model.notesOnCurrentTest else { return nil }
//            cell.resultsImageView.image = model.image
//            cell.resultsLabel.text = "RESULTS:\nScanType: \(scanType)\nCameraType: \(cameraType)\n Notes: \(notes)"
//
//                   return cell
//               }
//        self.tableView.dataSource = diffableDataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 500
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
//        self.snapshot.appendSections([1])
//        self.snapshot.appendItems(self.resultsArray)
//        self.diffableDataSource.apply(self.snapshot)
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
                let results = Results(scanType: nil, cameraType: nil, scanTypeString: scanTypeString, cameraTypeString: cameraTypeString, notesOnCurrentTest: data.value(forKey: "notes") as? String, image: nil, identifier: data.value(forKey: "identifier") as! NSUUID, timeStamp: data.value(forKey: "timeStamp") as? String, createdByUser: data.value(forKey: "createdByUser") as? String,  returnedText: data.value(forKey: "returnedText") as? String)
                self.resultsArray.append(results)
                
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

        self.resultsArray.count
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
       // cell.resultsImageView.image = UIImage(data: image!)
        cell.resultsLabel.text = "\(indexPath.row)"
       // cell.resultsLabel.text = "RESULTS:\nScanType: \(scanType)\nCameraType: \(cameraType)\n Notes: \(notes)\nCreated by \(user) at \(timeStamp)\n shows the text result: \(returnedText)"
        cell.resultsLabel.text = "result: \(returnedText)"
        return cell
    }
    
    
}
