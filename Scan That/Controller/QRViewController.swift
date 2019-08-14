//
//  QRViewController.swift
//  Scan That
//
//  Created by Kushal Mukherjee on 27/06/19.
//  Copyright © 2019 Kushal Mukherjee. All rights reserved.
//

import UIKit
import QRCode

class QRViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    
    var qrCode : QRCode?
    var qrString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        
        
        self.navigationItem.rightBarButtonItem = shareButton
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createQRImage()
    }
    
    
    @objc func share(){
        
        let shareItem = [qrImageView.image]
        
        let uiActivityController  = UIActivityViewController(activityItems: shareItem as [Any], applicationActivities: nil)
        present(uiActivityController, animated: true, completion: nil)
        
        
    }
    
    
    func createQRImage(){
        
        qrCode = QRCode(qrString)
        qrImageView.image = qrCode?.image
        
    }
}
