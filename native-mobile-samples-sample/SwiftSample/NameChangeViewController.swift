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
        print((newName.text)!)
        
        if(newName.text == ""){
            showMessage("Please enter a new display name")
        }
        else{
            
            showMessage("Changes saved")
            
            let request = buildAPIRequest()
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response,
                error) in
                print(data)
                // Check for error
                if error != nil
                {
                    print("error=\(error)")
                    return
                }
                print("HERE")
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let data = NSString(data: data!, encoding: NSUTF8StringEncoding)
                dispatch_async(dispatch_get_main_queue(), {
                    // code here
                    // self.songList = "Favorite Genre:  \(songs!)"
                    //ADD CELL TO TABLE VIEW
                    print(data!)
                    
                    
                })
                
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
        //print(urlString)
        let url = NSURL(string: urlString + "/secured/changeDisplayName")!
        //print(url)
        let request = NSMutableURLRequest(URL: url)
       
        request.HTTPMethod = "POST"
        //let params = ["song":"\(song)"] as Dictionary<String, String>
        let postString = "displayName=\(newname)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        print(request.HTTPBody)
    
    
    
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
