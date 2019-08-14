//
//  CreateQRViewController.swift
//  Scan That
//
//  Created by Kushal Mukherjee on 26/06/19.
//  Copyright © 2019 Kushal Mukherjee. All rights reserved.
//



/*
 Note: have to do empty field validations, create v card segment , char limit for email, layout contraints.
*/

import UIKit
import Bond



class CreateQRViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var qrCreateView: UIView!
    
    @IBOutlet weak var qrSegment: UISegmentedControl!
    
    var qrInfoTextFields : [UITextField] = []
    var qrInfo = String()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        urlQR()
        
       
        
        
        self.navigationItem.title = "Create"
        
        let generateQRButton = UIBarButtonItem(title: "Generate", style: .plain, target: self, action: #selector(generateQRImage))
        
        
        self.navigationItem.rightBarButtonItem = generateQRButton
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
       
    }
    
    
    
    @IBAction func selectQRType(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            urlQR()
        case 1:
            textQR()
        case 2:
            emailQR()
        default:
            urlQR()
        }
        
        
        
        
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let qrVC = segue.destination as? QRViewController
       
        qrVC?.qrString = self.qrInfo
        
        
    }
    
    @objc func generateQRImage(){
        
        switch qrSegment.selectedSegmentIndex {
        case 0,1:
            qrInfo=qrInfoTextFields.first?.text ?? ""
        case 2:
            qrInfo="mailto"
            print(qrInfo)
            for fields in qrInfoTextFields{
                qrInfo+=":\(fields.text!)"
                
            }
            
            
        default:
            qrInfo=""
        }
        
        print("Generate qr with info :\(qrInfo)")
        
    
        performSegue(withIdentifier: "createQrSegue", sender: self)
        
        
    }
    
    
    
    
    
    
    func urlQR(){
        resetQRView()
        
        let label = UILabel(frame: CGRect(x: 8, y: 20, width: 349, height: 59))
        label.text = "Enter URL:"
        label.sizeToFit()
        
        let textField = UITextField(frame: CGRect(x: 8, y: 60, width: 320, height: 40))
        
        textField.placeholder = "https://www.example.com"
        textField.borderStyle = .roundedRect
        
        
        
        qrInfoTextFields.append(textField)
  
        qrCreateView.addSubview(label)
        qrCreateView.addSubview(textField)
        }
    
    func textQR(){
        resetQRView()
        
        
        let label = UILabel(frame: CGRect(x: 8, y: 20, width: 349, height: 59))
        label.text = "Enter Text:"
        label.sizeToFit()
        
        let textField = UITextField(frame: CGRect(x: 8, y: 60, width: 320, height: 40))
        
        textField.placeholder = "Enter text here..."
        textField.borderStyle = .roundedRect
        textField.delegate = self
        
        let charRemLabel = UILabel(frame: CGRect(x: 8, y: 110, width: 50, height: 20))
        charRemLabel.textColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        
        
        textField.reactive.text.observe { (text) in
            
            if let fieldText = textField.text{
                
                if fieldText.count >= 140{
                    charRemLabel.textColor = .red
                    textField.allowsEditingTextAttributes = false
                    
                }
                else{
                    charRemLabel.textColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
                }
                charRemLabel.text = "You have \(140-fieldText.count) characters remaining"
            
                charRemLabel.sizeToFit()
            }
        }
        
        
        qrInfoTextFields.append(textField)
        
        qrCreateView.addSubview(label)
        qrCreateView.addSubview(textField)
        qrCreateView.addSubview(charRemLabel)

        
       
        
        
    }
    
   
    
    
    
    
    func emailQR(){
        resetQRView()
        
        let toLabel = UILabel(frame: CGRect(x: 8, y: 20, width: 349, height: 59))
        toLabel.text = "To:"
        toLabel.sizeToFit()
        
        let recepienttTextField = UITextField(frame: CGRect(x: 8, y: 60, width: 320, height: 40))
        
        recepienttTextField.placeholder = "Enter recepient mail id..."
        recepienttTextField.borderStyle = .roundedRect
        
        let mailLabel = UILabel(frame: CGRect(x: 8, y: 120, width: 349, height: 59))
        mailLabel.text = "Mail:"
        mailLabel.sizeToFit()
        
        let mailTextField = UITextField(frame: CGRect(x: 8, y: 160, width: 320, height: 40))
        
        mailTextField.placeholder = "Enter mail here..."
        mailTextField.borderStyle = .roundedRect
        
        qrInfoTextFields.append(recepienttTextField)
        qrInfoTextFields.append(mailTextField)
        
        qrCreateView.addSubview(toLabel)
        qrCreateView.addSubview(recepienttTextField)
        qrCreateView.addSubview(mailLabel)
        qrCreateView.addSubview(mailTextField)
        
    }
    
    
    
    
    //MARK: - Text field delegates
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        
        return updatedText.count <= 140
    }
    
    
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for textfields in qrInfoTextFields{
            textfields.resignFirstResponder()
        }
    }
    
    
    func resetQRView(){
        
        qrInfoTextFields=[]
        for subView in qrCreateView.subviews{
            
            subView.removeFromSuperview()
            
        }
        
        
    }
    

}
