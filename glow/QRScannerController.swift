//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController {
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession = AVCaptureSession()
    var upc = ""
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var barcodeAreaView: UIView?
    var backView: UIView?

    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = 350
        let height = 200

        print(self.view.frame.size.width)

        let xPos = (CGFloat(self.view.frame.size.width) / CGFloat(2)) - (CGFloat(width) / CGFloat(2))
        let yPos = (CGFloat(self.view.frame.size.height) / CGFloat(2)) - (CGFloat(height) / CGFloat(2))
        let barcodeArea = CGRect(x: Int(xPos), y: Int(yPos), width: width, height: height)

        barcodeAreaView = UIView()
        barcodeAreaView?.layer.borderColor = UIColor.green.cgColor
        barcodeAreaView?.layer.borderWidth = 2
        barcodeAreaView?.frame = barcodeArea
        
        backView = UIView()
        backView?.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.2156862745, blue: 1, alpha: 1)
        backView?.frame = self.view.frame
        backView?.mask(withRect: barcodeArea, inverse: true)
        
        view.addSubview(backView!)
        view.addSubview(barcodeAreaView!)

        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession.startRunning()
            captureMetadataOutput.rectOfInterest = videoPreviewLayer!.metadataOutputRectConverted(fromLayerRect: barcodeArea)

            // Move the message label and top bar to the front
            view.bringSubviewToFront(backView!)
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(topbar)
            view.bringSubviewToFront(barcodeAreaView!)

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
//        // Initialize QR Code Frame to highlight the QR code
//        qrCodeFrameView = UIView()
//
//        if let qrCodeFrameView = qrCodeFrameView {
//            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
//            qrCodeFrameView.layer.borderWidth = 2
//            view.addSubview(qrCodeFrameView)
//            view.bringSubviewToFront(qrCodeFrameView)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Open App", message: "You're going to open \(decodedURL)", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
//            self.getScanApiCall(str: self.upc)
            self.scanFirstApiCall(str: self.upc)
            //            if let url = URL(string: decodedURL) {
            //                if UIApplication.shared.canOpenURL(url) {
            //                    UIApplication.shared.open(url)
            //                }
            //            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
            self.captureSession.startRunning()
        })
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = self.view.bounds
    }
    
    
    func scanFirstApiCall(str: String) {
        Utility.showProgress()
        SearchRequest.searchProductForAsin(param: str) { (success, search, error) in
            if error != nil {
                Utility.dismissProgress()
                self.getScanApiCall(str: str)
            } else {
                if let response = search as? [String:Any] {
                    if let asin = response["asin"] as? String {
                        Utility.showProgress()
                        let param = ["keywords" : asin,
                                     "marketplace" : "JP"] as [String : Any]
                        SearchRequest.searchProductFromAsin(param: param) { (success, result, error) in
                            if error == nil, let search = result {
                                Utility.dismissProgress()
                                self.moveToResult(search: search.map { $0.toSearch() })
                            } else {
                                let param = ["asin" : asin,
                                             "country" : "JP"] as [String : Any]
                                Utility.showProgress()
                                SearchRequest.searchProductFromUrl(param: param) { (success, result, error) in
                                    if error == nil, let search = result {
                                        if !(search.thumbnail ?? "").isEmpty || (search.images?.count ?? 0) > 0 {
                                            Utility.dismissProgress()
                                            self.moveToResult(search: [search])
                                        } else {
                                            SearchRequest.searchProduct(param: ["keyword": search.asin ?? "", "country": "US", "category": "aps"]) { success, result, error in
                                                if result?.data == nil {
                                                    SearchRequest.searchProductDetail(param: ["keyword": search.asin ?? "", "domainCode": "co.jp", "page": 1]) { success, response, error in
                                                        Utility.dismissProgress()
                                                        let data = (response ?? []).first(where: { $0.asin == search.asin })
                                                        search.thumbnail = data?.imgUrl
                                                        self.moveToResult(search: [search])
                                                    }
                                                } else {
                                                    Utility.dismissProgress()
                                                    let data = (result?.data ?? []).first(where: { $0.asin == search.asin })
                                                    search.thumbnail = data?.thumbnail
                                                    self.moveToResult(search: [search])
                                                }
                                            }
                                        }
                                    } else {
                                        Utility.alert(message: "", title: "該当商品がございませんでした。")
                                    }
                                }
                            }
                        }
                    } else {
                        self.getScanApiCall(str: str)
                    }
                } else {
                    self.getScanApiCall(str: str)
                }
            }
        }
    }
    
    func moveToResult(search: [Search]) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController {
            viewController.searchList = search
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func getScanApiCall(str: String) {
        Utility.showProgress()
        SearchRequest.searchProductFromBarcode(param: ["search": str]) { status, response, error in
            Utility.dismissProgress()
            if error != nil {
                self.searchBarCodeData(barcode: str)
            } else {
                if let res = response, let data = res.data {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    if let viewController = storyBoard.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController {
                        viewController.searchList = data
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            }
        }

    }
    
    func getProductUrl(str: String) -> String {
        let tempUrl = "https://www.amazon.co.JP/dp/" + str
        return tempUrl
    }
    
    func searchBarCodeData(barcode: String) {
        Utility.showProgress()
        SearchRequest.searchProductFromBarcode(param: barcode) { success, response, error in
            Utility.dismissProgress()
            if error == nil {
                if let ean = response?.ean {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    if let viewController = storyBoard.instantiateViewController(withIdentifier: "VideoRecordingViewController") as? VideoRecordingViewController {
                        let productUrl = self.getProductUrl(str: ean)
                        let searchData = Search(asin: ean,
                                                price: "",
                                                title:  response?.title ?? "",
                                                thumbnail: response?.images?.first ?? "",
                                                url: productUrl,
                                                images: [])
                        viewController.searchData = searchData
                        viewController.modalPresentationStyle = .overFullScreen
                        self.present(viewController, animated: true, completion: nil)
                    } else {
                        Utility.alert(message: "", title: "該当商品がございませんでした。")
                    }
                } else {
                    Utility.alert(message: "", title: "該当商品がございませんでした。")
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.videoPreviewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            if supportedCodeTypes.contains(readableObject.type) {
                // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
//                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: readableObject)
//                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                if readableObject.stringValue != nil {
                    print(readableObject.stringValue)
                    launchApp(decodedURL: readableObject.stringValue!)
                    messageLabel.text = readableObject.stringValue
                    self.upc = readableObject.stringValue ?? ""
                    captureSession.stopRunning()
                }
            }
        }
    }
    
}
