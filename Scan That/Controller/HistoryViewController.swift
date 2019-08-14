//
//  HistoryViewController.swift
//  Scan That
//
//  Created by Kushal Mukherjee on 17/07/19.
//  Copyright © 2019 Kushal Mukherjee. All rights reserved.
//

import UIKit
import CoreData
import PopupDialog
import SafariServices

class HistoryViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var historyTableView: UITableView!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var codesArray = [QrCodeInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        
        self.navigationItem.title = "History"
        
        historyTableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "history")
        historyTableView.rowHeight = 50.5
        
        
        

        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchCodes()
        
    }
    
    //MARK: - Fetching qr codes
    
    func fetchCodes(){
        
        let request : NSFetchRequest<QrCodeInfo> = QrCodeInfo.fetchRequest()
        do{
        codesArray = try context.fetch(request)
            print("Fetched:\(codesArray)")
            historyTableView.reloadData()
        }
        catch{
            print("Error while fetching codes.")
        }
    }
    

    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return codesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let codeInfo = codesArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryTableViewCell
        cell.cellImage.image = UIImage(named: "activityhistory")
        cell.mainLabel.text = codeInfo.code
        let dtFrmtr = DateFormatter()
        dtFrmtr.dateFormat = "dd-MMM-yy"
        
        cell.dateLabel.text = dtFrmtr.string(from: codeInfo.date!)
        cell.cellImage.image = UIImage(named: codeInfo.category!)
        
        cell.mainLabel.sizeToFit()
        cell.dateLabel.sizeToFit()
        
//        cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
//        cell.cellImage.tintColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 1)
        
        
        return cell
        
        
    }
    
    //MARK: - Tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let code = codesArray[indexPath.row].code!
        let title = "Scan success"
        let message = code
        let popUpDialog = PopupDialog(title: title, message: message){
            self.viewWillAppear(true)
        }
        
        //for url
        if code.isValidUrl(url: code){
            
            
            let openSafariButton = PopupDialogButton(title: "Open safari") {
                self.openSafari(url: code)
            }
            popUpDialog.addButton(openSafariButton)
            
            
        }
            
            //for phone
        else if code.uppercased().starts(with: "TEL"){
            
            
            let openPhoneButton = PopupDialogButton(title: "Make a call"){
                let url = URL(string: code)
                UIApplication.shared.open(url!)
                
                
            }
            popUpDialog.addButton(openPhoneButton)
            
        }
            
            //for sms
        else if code.uppercased().starts(with: "SMS"){
           
            
            
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
                    
                   
                    
                    let genButton = PopupDialogButton(title: "Open") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    popUpDialog.addButton(genButton)
                }
                else{
                    //no app found
                }
            }
            else{
               
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
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
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
