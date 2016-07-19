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
        
        
    }
    
    private func buildAPIRequest() -> NSURLRequest {
        let newname = (newName.text)!
        let keychain = MyApplication.sharedInstance.keychain
        let profileData:NSData! = keychain.dataForKey("profile")
        let profile:A0UserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(profileData) as! A0UserProfile
        let user_id = profile.userId
        //print(user_id)
        //let postString = "user_metadata={\"displayName\": \"\(newname)\"}"
    
        let encodedUserId =  user_id.stringByAddingPercentEncodingWithAllowedCharacters(NSMutableCharacterSet.URLQueryAllowedCharacterSet())!
        //print(encodedUserId)
        let urlString = "https://eliharkins.auth0.com/api/v2/users/" + encodedUserId
        //print(urlString)
        let url = NSURL(string: urlString)!
        //print(url)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PATCH"
        let dict = ["user_metadata": ["displayName": newname]]
        
        //let data = NSKeyedArchiver.archivedDataWithRootObject(dict)
        
        
        
        
        if let bodyJSON = try? NSJSONSerialization.dataWithJSONObject(dict, options: [NSJSONWritingOptions.PrettyPrinted]){
            request.HTTPBody = bodyJSON // as? NSData
            //print(bodyJSON)
            //print("THIS ONE " + request.HTTPBody!.base64EncodedStringWithOptions([]))

        }
       
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        
        let token = keychain.stringForKey("id_token")!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    





}
