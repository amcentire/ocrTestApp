//
//  AVViewController.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 10/1/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit

class AVViewController: UIViewController {
    
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("camera view is \(cameraView.debugDescription)")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
