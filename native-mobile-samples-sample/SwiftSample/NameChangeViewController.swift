//
//  NameChangeViewController.swift
//  SwiftSample
//
//  Created by Elias Harkins on 7/14/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

import UIKit
import Lock
import AFNetworking
import Foundation



class NameChangeViewController: UIViewController{
    
    

    @IBOutlet var newName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
   
    @IBAction func changeName(sender: AnyObject) {
        if(newName.text == ""){
            showMessage("Please enter a new display name")
        }
        else{
            
            showMessage("Changes saved")
            
            let request = buildAPIRequest()
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response,
                error) in
                if error != nil
                {
                    print("error=\(error)")
                    return
                }
                
            }
            task.resume()
            
            newName.text = ""
            
            
        }
        
    }
    
    private func buildAPIRequest() -> NSURLRequest {
        let newname = (newName.text)!
        let keychain = MyApplication.sharedInstance.keychain
        let info = NSBundle.mainBundle().infoDictionary!
        let urlString = info["SampleAPIBaseURL"] as! String
        let url = NSURL(string: urlString + "/displayName/change")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let postString = "displayName=\(newname)"
    
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    
        let token = keychain.stringForKey("id_token")!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertView(title: message, message: nil, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }


}
