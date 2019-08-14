//
//  ViewController.swift
//  Scan That
//
//  Created by Kushal Mukherjee on 19/06/19.
//  Copyright © 2019 Kushal Mukherjee. All rights reserved.
//

import UIKit
import CoreData
import SafariServices
import Alamofire
import SwiftyJSON
import AVFoundation
import SVProgressHUD
import PopupDialog

class ScanViewController: CodeScannerController {
    
    
    let API_KEY="C22730B70102A7D1764F9403C297E3D7"
     var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Scan"
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func found(code: String,metaDataOutput:AVMetadataObject.ObjectType = AVMetadataObject.ObjectType(rawValue: "org.iso.QRCode")) {
        if(metaDataOutput.rawValue == "org.iso.QRCode"){
            qrCodeScan(code)
        }
//        else{
//
//            SVProgressHUD.show()
//
//
//            DispatchQueue.global(priority: .default).async{
//
//                self.fromUPC(barcode: code)
//                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss()
//                }
//            }
//                 
//        }
    }
    
    
        
//    func fromUPC(barcode:String){
//        var url="https://api.upcdatabase.org/product/"
//        url+="\(barcode)/\(API_KEY)"
        
//        var url = "https://samples.openweathermap.org/data/2.5/forecast?id=524901&appid=b1b15e88fa797225412429c1c50c122a1"
//        print(url)
//
//
//
//        Alamofire.request(url).responseJSON { (response) in
//            if(response.result.isSuccess){
//                print(try! JSON(data:response.data!))
//            }
//            else{
//                print(response.result.error?.localizedDescription)
//            }
//        }
//        if let url = URL(string:  "https://www.google.com/search?q=\(barcode)&oq=\(barcode)&aqs=chrome..69i57j69i60l4j69i59.2378j0j4&sourceid=chrome&ie=UTF-8") {
//            let config=SFSafariViewController.Configuration()
//
//
//            let vc = SFSafariViewController(url: url,configuration: config)
//            present(vc, animated: true)
//        }
//
//
//
//
//    }
    
    //MARK: - QRCode Scan
    
    func qrCodeScan(_ code:String){
        
        //setting up pop up dialog
        let title = "Scan success"
        let message = code
        let popUpDialog = PopupDialog(title: title, message: message){
            self.viewWillAppear(true)
        }
        
        
        
        let newCode = QrCodeInfo(context: self.context)
        newCode.code = code
        newCode.date = Date()
        
        //for url
        if code.isValidUrl(url: code){
            newCode.category = "url"

            let openSafariButton = PopupDialogButton(title: "Open safari") {
                self.openSafari(url: code)
            }
            popUpDialog.addButton(openSafariButton)
            
            
        }
            
        //for phone
        else if code.uppercased().starts(with: "TEL"){
            newCode.category = "phone"

            let openPhoneButton = PopupDialogButton(title: "Make a call"){
                let url = URL(string: code)
                UIApplication.shared.open(url!)
                
                
            }
            popUpDialog.addButton(openPhoneButton)
            
        }
            
        //for sms
        else if code.uppercased().starts(with: "SMS"){
            newCode.category = "sms"

            
            let smsArr = code.split(separator: ":")
            
            print("Text to:\(smsArr[1])")
            print("Text message:\(smsArr[2])")
            
            
            
            
            
            
            let openMessageButton = PopupDialogButton(title: "Send Message"){
                if let url = URL(string: "sms://\(smsArr[1])"){
                    UIApplication.shared.open(url)
                }
                
                
            }
            popUpDialog.addButton(openMessageButton)
        }
            
        //for mail
        else if code.uppercased().starts(with: "MAIL"){
            newCode.category = "mail"

            
            let openMailButton = PopupDialogButton(title: "Send Mail"){
                let url = URL(string: code)
                UIApplication.shared.open(url!)
                
                
            }
            popUpDialog.addButton(openMailButton)
        }
            
        //default scenario
            
        else{
            if let url = URL(string: code){
            
                if UIApplication.shared.canOpenURL(url){
                
                    newCode.category = "url"
                
                    let genButton = PopupDialogButton(title: "Open") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    popUpDialog.addButton(genButton)
                }
                else{
                    newCode.category = "text"
                    //no app found
                }
            }
            else{
                newCode.category = "text"
            }
            
            
        }
        
        //copy to clipboard
        let copyButton = PopupDialogButton(title: "Copy"){
            UIPasteboard.general.string = code
        }
        
        //sharing options
        let shareButton = PopupDialogButton(title: "Share") {
            let uiactivityController = UIActivityViewController(activityItems: [code], applicationActivities: nil)
            self.present(uiactivityController, animated: true)
        }
        popUpDialog.addButton(copyButton)
        popUpDialog.addButton(shareButton)
        
        popUpDialog.buttonAlignment = .vertical
        
        present(popUpDialog, animated: true, completion: nil)
        
        
        
        saveCode(code)
        
    }
    
    //MARK:- Saving code to core data
    
    func saveCode(_ code:String){
        
        
        do{
            
        try context.save()
            print("Code saved")
        }
        catch{
            print("Error while saving qr code info")
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    //MARK:- Opening Safari
    
    func openSafari(url:String){
        if let url = URL(string: url) {
            let config=SFSafariViewController.Configuration()
            
            
            let vc = SFSafariViewController(url: url,configuration: config)
            present(vc, animated: true)
        }
    }
    
    
    
    
    
    




}
extension ScanViewController{
    
    //MARK: - Image picker delegate
    
    //the image picker is added in CodeScannerController. The functionality is implemented in here.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let qrImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            let ciImage = CIImage(image: qrImage) ?? CIImage()
            let detector : CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options:
                [CIDetectorAccuracy:CIDetectorAccuracyHigh]) ?? CIDetector()
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature] ?? []
            DispatchQueue.main.async {
                if let code = features.first?.messageString{
                    self.found(code: code)
                }
                
            }
            
            
            
            
        }
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
}




extension String{
    
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
}
