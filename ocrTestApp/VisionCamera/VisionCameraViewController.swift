//
//  VisionCameraViewController.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 10/1/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class VisionCameraViewController: UIViewController {


    @IBOutlet weak var imageView: UIImageView!
    // Vision requests to be performed on each page of the scanned document.
    private var requests = [VNRequest]()
    // Dispatch queue to perform Vision requests.
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var resultingText = ""
    
    // Setup Vision request as the request can be reused
    private func setupVision() {
        
            }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
      
        setupVision()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    @IBAction func scanReceipts(_ sender: UIControl?) {
        self.loadView()
        
    }
}

// MARK: VNDocumentCameraViewControllerDelegate

extension VisionCameraViewController: VNDocumentCameraViewControllerDelegate {
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Clear any existing text.
        // dismiss the document camera
        controller.dismiss(animated: true)
        
        textRecognitionWorkQueue.async {
            self.resultingText = ""
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    self.imageView.image = image
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    
                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error)
                    }
                }
                self.resultingText += "\n\n"
            }
            DispatchQueue.main.async(execute: {
                
            })
        }

    }
}
