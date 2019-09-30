//
//  ViewController.swift
//  sampleOCRproject
//
//  Created by Allison McEntire on 9/4/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit
import Vision
import VisionKit
import CoreData

class ScanImagesViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    private var textRequest = [VNRequest]()
    private var rectangleRequest = [VNRequest]()
    private var scanType: ScanType?
    private var cameraType: CameraType?
    
    public var passedResults: Results?
    
    
    // Dispatch queue to perform Vision requests.
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
   
    
    let image = UIImage(named: "test")
    var sliceArray = [UIImage]()
    var resultingText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupVision()
        guard let rotatedImage = self.image?.rotate(radians: 3 * .pi/2) else { return }
        if let cgImage = rotatedImage.cgImage {
            self.performVisionRequest(image: cgImage)
        }

        imageView.image = rotatedImage
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.passedResults = self.getTestParameters()
                
    }
    
    //MARK - VNDetectTextRectanglesRequest
    
    lazy var rectangleTextDetectionRequest: VNDetectTextRectanglesRequest = {
        let rectDetectRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleDetectedTextRectangles)
        // Customize & configure the request to detect only certain rectangles.
       rectDetectRequest.reportCharacterBoxes = true
       
        return rectDetectRequest
    }()
    
    private func performVisionRequest(image: CGImage) {
        
        // Fetch desired requests based on switch status.
      self.rectangleRequest = [rectangleTextDetectionRequest]
        // Create a request handler.
      let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        
        // Send the requests to the request handler.
      DispatchQueue.global(qos: .userInitiated).async {
            do {
              try imageRequestHandler.perform(self.rectangleRequest)
            } catch _ as NSError {
                return
            }
        }
    }
    
    private func handleDetectedTextRectangles(request: VNRequest?, error: Error?) {
        guard let observations = request?.results else {
            return
        }

        let result = observations.map({$0 as? VNTextObservation})

        DispatchQueue.main.async() {
            self.imageView.layer.sublayers?.removeSubrange(1...)
            if let largeImage = self.imageView.image {

                for region in result {

                    if let boxes = region?.characterBoxes {

                        for characterBox in boxes {
                            if let newSlice = self.cropped(box: characterBox, image: largeImage) {
                                self.sliceArray.append(newSlice)
                            }

                        }

                    }
                }
            }

            //MARK - pass cropped character images to VNRecognizeTextRequest
            for image in self.sliceArray {
                self.analyzeImageForText(image: image)
            }
            
        }
        
    }
    
    //MARK - VNRecognizeTextRequest
    
    private func setupVision() {
           let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
               guard let observations = request.results as? [VNRecognizedTextObservation] else {
                   return
               }
               // Concatenate the recognised text from all the observations.
               let maximumCandidates = 1
               for observation in observations {
                   guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                   self.resultingText += candidate.string + "\n"
               }
           }
           textRecognitionRequest.recognitionLevel = .fast
           textRecognitionRequest.usesLanguageCorrection = false
           self.textRequest = [textRecognitionRequest]
      }
      

      private func analyzeImageForText(image: UIImage) {
    
          textRecognitionWorkQueue.async {
              self.resultingText = ""
              let image = image
              if let cgImage = image.cgImage {
                  let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                      do {
                          try requestHandler.perform(self.textRequest)
                      } catch {
                          print(error)
                      }
                  }
              self.resultingText += "\n\n"
              print("resulting text \(self.resultingText)")
          }
      }
    
    //MARK - helper methods
    
    private func cropped(box: VNRectangleObservation, image: UIImage) -> UIImage? {

        guard let cgImage = image.cgImage else { return nil }
        
        let xCord = box.topLeft.x * image.size.width
        let yCord = (1 - box.topLeft.y) * image.size.height
        let width = (box.topRight.x - box.topLeft.x) * image.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * image.size.height
        let expandedCrop = CGRect(x: xCord, y: yCord, width: width, height: height).inset(by: UIEdgeInsets(top: -5.0, left: -5.0, bottom: -5.0, right: -5.0))
                 
        guard let croppedImage = cgImage.cropping(to: expandedCrop) else { return nil }
        let rotatedImage = UIImage(cgImage: croppedImage).rotate(radians: -3 * .pi/2)
        return rotatedImage
    }
    
    func getTestParameters() -> Results? {
        
        
        
        
        var results: Results?
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TestResults")
        do {
            let result = try managedContext?.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let scanTypeString = data.value(forKey: "scanType") as? String
                let cameraTypeString = data.value(forKey: "cameraType") as? String
                let scanType = self.passedResults?.updateScanType(string: scanTypeString)
                let cameraType = self.passedResults?.updateCameraType(string: cameraTypeString)
                results = Results(scanType: scanType, cameraType: cameraType, scanTypeString: scanTypeString, cameraTypeString: cameraTypeString, notesOnCurrentTest: data.value(forKey: "notes") as? String, image: data.value(forKey: "image") as? UIImage, identifier: data.value(forKey: "identifier") as! NSUUID, timeStamp: data.value(forKey: "timeStamp") as? String, createdByUser: data.value(forKey: "createdByUser") as? String)
                
            }
                
            }
            catch {
                
            }
        return results
    }
    
    func updateTypes() {
        self.scanType = self.passedResults?.updateScanType(string: passedResults?.scanTypeString)
        self.cameraType = self.passedResults?.updateCameraType(string: passedResults?.cameraTypeString)
    }

}

// MARK - extensions

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()

        // Move origin to middle
        context?.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context?.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    

}



