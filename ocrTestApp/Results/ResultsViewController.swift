//
//  ResultsViewController.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 9/30/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
    var passedResult: Results?

    @IBOutlet weak var tableView: UITableView!
    
    private var diffableDataSource: UITableViewDiffableDataSource<Int, Results>!
    private var snapshot = NSDiffableDataSourceSnapshot<Int, Results>()
    
    public var resultsArray = [Results]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshot.appendItems(self.resultsArray)
        self.diffableDataSource.apply(self.snapshot)
        
        
        diffableDataSource = UITableViewDiffableDataSource<Int, Results>(tableView: tableView) { (tableView:UITableView, indexPath:IndexPath, model: Results) -> ResultsTableViewCell? in
                   let cell: ResultsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell", for: indexPath) as! ResultsTableViewCell
            guard let scanType = self.resultsArray[indexPath.row].scanType else { return nil }
            guard let cameraType = self.resultsArray[indexPath.row].cameraType else { return nil }
            guard let notes = self.resultsArray[indexPath.row].notesOnCurrentTest else { return nil }
            cell.resultsImageView.image = self.resultsArray[indexPath.row].image
            cell.resultsLabel.text = "RESULTS:\nScanType: \(scanType)\nCameraType: \(cameraType)\n Notes: \(notes)"
                   
                   return cell
               }
               tableView.dataSource = diffableDataSource
               tableView.tableFooterView = UIView()
               tableView.rowHeight = UITableView.automaticDimension
               tableView.estimatedRowHeight = 50
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }


}
