//
//  CodeScannerController.swift
//  Scan That
//
//  Created by Kushal Mukherjee on 20/06/19.
//  Copyright © 2019 Kushal Mukherjee. All rights reserved.
//

import UIKit
import AVFoundation

class CodeScannerController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var captureDevice:AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        
        
        
        
        captureSession = AVCaptureSession()
        
        captureDevice = AVCaptureDevice.default(for: .video)
        guard let videoCaptureDevice = captureDevice else { return }
        
        let videoInput: AVCaptureDeviceInput
        
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr,.aztec,.code128,.code39,.code39Mod43,.code93,.dataMatrix,.ean13,.ean8,.interleaved2of5,.itf14,.upce]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        
        cameraAccessories()
        
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        
            
            
            
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            found(code: stringValue, metaDataOutput: metadataObject.type)
        }
        
//        dismiss(animated: true)
    }
    
    func found(code: String,metaDataOutput:AVMetadataObject.ObjectType){
        
    }
    
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    //
    //    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    //        return .portrait
    //    }
}

extension CodeScannerController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func cameraAccessories(){
        
//        let myView = UIView(frame: CGRect(x: 100, y: 550, width: 180, height: 30))
        let myView = UIView()
        myView.backgroundColor = UIColor.white
        myView.alpha = 0.5
        myView.layer.cornerRadius = 10
        view.addSubview(myView)
        
        
        myView.translatesAutoresizingMaskIntoConstraints = false
        
        myView.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 0).isActive = true
        myView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
        
        myView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        myView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
        
        let flashOnButton = UIButton(type: .roundedRect)
        flashOnButton.frame = CGRect(x: 100, y: -10, width: 50, height: 50)
        flashOnButton.setImage(UIImage(named: "flashoff"), for: .normal)
        flashOnButton.tintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        flashOnButton.addTarget(self, action: #selector(flashButtonAction(sender:)), for: .touchDown)
        
//        flashOnButton.translatesAutoresizingMaskIntoConstraints=false
//        flashOnButton.leftAnchor.constraint(equalTo: myView.centerXAnchor, constant: 10).isActive = true
//        flashOnButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        flashOnButton.topAnchor.constraint(equalTo: myView.centerYAnchor, constant: -10).isActive = true
//        flashOnButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let galleryButton = UIButton(type: .roundedRect)
        galleryButton.frame = CGRect(x: 40, y: -10, width: 50, height: 50)
        galleryButton.setImage(UIImage(named: "gallery"), for: .normal)
        galleryButton.tintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        galleryButton.addTarget(self, action: #selector(galleryButtonAction(sender:)), for: .touchDown)
        
        
        myView.addSubview(flashOnButton)
        myView.addSubview(galleryButton)
        
    }
    
    @objc func flashButtonAction(sender : UIButton){
        
        guard let videoCaptureDevice = captureDevice else {return}
        
        if videoCaptureDevice.hasTorch{
            
            try? videoCaptureDevice.lockForConfiguration()
            if videoCaptureDevice.torchMode == .off{
                videoCaptureDevice.torchMode = .on
                sender.setImage(UIImage(named: "flashon"), for: .normal)
            }
            else{
                  videoCaptureDevice.torchMode = .off
                sender.setImage(UIImage(named: "flashoff"), for: .normal)
                }
            videoCaptureDevice.unlockForConfiguration()
            
        }
        
    }
    
    @objc func galleryButtonAction(sender : UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    
}


