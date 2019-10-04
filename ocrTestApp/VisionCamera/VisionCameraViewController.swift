//
//  VisionCameraViewController.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 10/1/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Vision
import VisionKit
import MediaPlayer
import CoreData

class VisionCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

   
    @IBOutlet weak var cameraView: UIView!
    
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    public var containerCode: String?
    private var textRequest = [VNRequest]()
    private var rectangleRequest = [VNRequest]()
    // Dispatch queue to perform Vision requests.
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    var resultsArray = [String]()
    var sliceArray = [UIImage]()
    private var resultingText = ""
    private var imageToAnalyze: UIImage?
    public var flatCode: String?
    
    public var scanType: ScanType?
    public var cameraType: CameraType = .scan
    public var titleText = "Scan Code"
    public var passedResults: Results?
    public var paddingFloat: CGFloat = -5.0
    public var processingType: String?
    
    override func viewDidLoad() {
        
        //TO DO: CHANGE CAMERA BASED ON CHOICE OF CAMERA TYPE
        //TO DO: store and fetch image data
        
        setupVision()
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        self.navigationController?.present(documentCameraViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.resultsArray.removeAll()
        self.sliceArray.removeAll()
    }
    
   
    func setupVision() {
        
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
         // specify the recognition level
        
        switch self.scanType {
        case .containerCode:
            textRecognitionRequest.recognitionLevel = .fast
            textRecognitionRequest.minimumTextHeight = 0.99
            textRecognitionRequest.customWords = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        case .sealCode:
            textRecognitionRequest.recognitionLevel = .accurate
        case .tareWeight:
            textRecognitionRequest.recognitionLevel = .accurate
        case .none:
            break
        }
 
         textRecognitionRequest.usesLanguageCorrection = false
        

         self.textRequest = [textRecognitionRequest]
    }
    
    
    func photoOutput(image: UIImage) {
        self.resultsArray.removeAll()
        self.sliceArray.removeAll()
    
        
        guard let rotatedImage = image.rotate(radians: 3 * .pi/2) else { return }
        
        switch self.scanType {
        case .containerCode:
            self.imageToAnalyze = rotatedImage
            if let cgImage = rotatedImage.cgImage {
                DispatchQueue.main.async {
                    print("performing request")
                    self.performVisionRequest(image: cgImage)
                }
            }
        case .sealCode:
            self.imageToAnalyze = image
            self.analyzeImageForText(image: image, completion: { (code) -> Void in
                DispatchQueue.main.async {
                    self.captureResults(image: image, returnedText: code)
                }
            })

        case .tareWeight:
            self.imageToAnalyze = image
            self.analyzeImageForText(image: image, completion: { (code) -> Void in
                DispatchQueue.main.async {
                    self.captureResults(image: image, returnedText: code)
                }
            })

        case .none:
            break
        }

        
        
    }
    
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
            if let largeImage = self.imageToAnalyze {

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
            for image in self.sliceArray {
                self.analyzeImageForText(image: image, completion: { (code) -> Void in
                    self.flatCode = code
                    self.captureResults(image: image, returnedText: code)
                })
                
            }
            
        }
        
    }
    
    private func analyzeImageForText(image: UIImage, completion: @escaping (String) -> ()) {
        
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
            //self.resultingText += "\n\n"
            
            let result = self.resultingText
            
            
            
            switch self.scanType {
                   case .containerCode:
                    let trimmedResult = result.replacingOccurrences(of: "[\n|*|?|&|.|•|~|`|!|@|#|$|%|^|(|)|{|}|+|=|-|_|<|>|°|/]", with: "", options: .regularExpression)
                       if trimmedResult.utf16.count != 1 {
                                      print("result \(trimmedResult) discarded")
                                  }
                                  else {
                                      self.resultsArray.append(trimmedResult)
                                  }
                   case .sealCode:
                    let trimmedResult = result.replacingOccurrences(of: "[\n|*|?|&|.|•|~|`|!|@|#|$|%|^|(|)|{|}|+|=|_|<|>|°|/]", with: "", options: .regularExpression)
                    self.resultsArray.append(self.resultingText)
                   case .tareWeight:
                    let trimmedResult = result.replacingOccurrences(of: "[\n|*|?|&|.|•|~|`|!|@|#|$|%|^|(|)|{|}|+|=|-|_|<|>|°|/|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|,]", with: "", options: .regularExpression)
                       self.resultsArray.append(trimmedResult)
                   case .none:
                       break
            }
            
            let code = self.resultsArray.joined(separator: "")
            print("results array \(self.resultsArray)")
            
            completion(code)
           
          }
        
      }
    
    private func captureResults(image: UIImage, returnedText: String){
        
        let results = Results(scanType: self.scanType, cameraType: self.cameraType, scanTypeString: self.scanType?.updateTitle(), cameraTypeString: self.cameraType.updateTitle(), notesOnCurrentTest: self.passedResults?.notesOnCurrentTest, image: image.jpegData(compressionQuality: 1.0) as! Data, identifier: NSUUID(), timeStamp: self.passedResults?.timeStamp, createdByUser: self.passedResults?.createdByUser,  returnedText: returnedText)

        DispatchQueue.main.async {
            self.createDatabaseObject(results: results)
        }
        
    }
    
    

    //MARK - helper methods
    
    private func scanRegex(code: String) -> Bool {
        
        var pattern: String {
        
            switch self.scanType {
            case .containerCode:
                return "[A-Z]{3}[U]{1}[0-9]{7}"
            case .sealCode:
                return "[A-Z]{2}[-]{1}[0-9]{7}"
            case .tareWeight:
                return "[0-9]{5}"
            case .none:
                return ""
            }
        }
        
        let range = code.range(of: pattern, options: .regularExpression)
        if range != nil {
            return true
        }
        return false
    }
    
    private func cropped(box: VNRectangleObservation, image: UIImage) -> UIImage? {

        guard let cgImage = image.cgImage else { return nil }
        
        let xCord = box.topLeft.x * image.size.width
        let yCord = (1 - box.topLeft.y) * image.size.height
        let width = (box.topRight.x - box.topLeft.x) * image.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * image.size.height
        let expandedCrop = CGRect(x: xCord, y: yCord, width: width, height: height).inset(by: UIEdgeInsets(top: -paddingFloat, left: -paddingFloat, bottom: -paddingFloat, right: -paddingFloat))
                 
        guard let croppedImage = cgImage.cropping(to: expandedCrop) else { return nil }
        let rotatedImage = UIImage(cgImage: croppedImage).rotate(radians: -3 * .pi/2)
        return rotatedImage
    }
    
    private func createDatabaseObject(results: Results) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let testResultsEntity = NSEntityDescription.entity(forEntityName: "TestResults", in: managedContext) else { return }
               
        let testResults = NSManagedObject(entity: testResultsEntity, insertInto: managedContext)
        testResults.setValue(results.scanType?.updateTitle(), forKey: "scanType")
        testResults.setValue(results.cameraType?.updateTitle(), forKey: "cameraType")
        testResults.setValue(results.getCurrentUser(), forKey: "createdByUser")
        testResults.setValue(results.generateCurrentTimeStamp(), forKey: "timeStamp")
        testResults.setValue(results.identifier, forKey: "identifier")
        testResults.setValue(results.notesOnCurrentTest, forKey: "notes")
        testResults.setValue(results.returnedText, forKey: "returnedText")
        testResults.setValue(results.image, forKey: "image")
        
        
        do {
            try managedContext.save()
            }
            catch {
                print("Error")
            }
               
    }

    

    
}

// MARK: VNDocumentCameraViewControllerDelegate

extension VisionCameraViewController: VNDocumentCameraViewControllerDelegate {
    
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
 
            for pageIndex in 0 ..< scan.pageCount {
                self.imageToAnalyze = scan.imageOfPage(at: pageIndex)
                let image = scan.imageOfPage(at: pageIndex)
                    DispatchQueue.main.async {
                        print("image from doc scanner \(image.debugDescription)")
                        self.photoOutput(image: image)
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                
                
            }
        }

    
}
