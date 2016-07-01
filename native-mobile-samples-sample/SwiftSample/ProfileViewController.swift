// ProfileViewController.swift
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Lock
import AFNetworking
import Foundation



class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var inputSong: UITextField!

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var favGenre: UILabel!
    @IBOutlet var songList: UITableView!
    
    let cellIdentifier = "CellIdentifier"
    var songs: [String]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSongs()
        
        let keychain = MyApplication.sharedInstance.keychain
        let profileData:NSData! = keychain.dataForKey("profile")
        let profile:A0UserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(profileData) as! A0UserProfile
        self.profileImage.setImageWithURL(profile.picture)
        
        let displayName = profile.userMetadata["displayName"]!
        //print(displayName)
        
        self.welcomeLabel.text = "Welcome \(displayName)!"

        getRoles(profile)
        //print(keychain.stringForKey("id_token"))
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = songs.count
        return numberOfRows
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        // Fetch song
        let song = songs[indexPath.row]
        
        // Configure Cell
        cell.textLabel?.text = song
        
        return cell
    }

    @IBAction func getGenre(sender: AnyObject) {
        let request = buildAPIRequest("/secured/getFavGenre", type:"GET")
//        let manager = AFHTTPSessionManager()
//            manager.dataTaskWithRequest(request) { [unowned self] data, response, error in
//            guard let _ = error else { return self.showMessage("Please download the API seed so that you can call it.") }
//            self.showMessage("We got the secured data successfully")
//            }.resume()

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {[unowned self](data, response, error) in
            //print(NSString(data: data, encoding: NSUTF8StringEncoding));
            let genre = NSString(data: data!, encoding: NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                self.favGenre.text = "Favorite Genre:  \(genre!)"
                print(genre!)

            })
            
           

        }
        
        task.resume()
    }
    
    //            self.completionHandler(response, error: error!)
    //    private func completionHandler(response: AnyObject?, error: ErrorType){
    //        self.showMessage("We got the secured data successfully: \(response), error?: \(error)")
    //
    //    }
    
    private func getRoles(profile:A0UserProfile){
      // ACCESS USER OBJECT THROUGH profile VARIABLE ASSIGNED ABOVE AND UPDATE WELCOME BANNER ACCORDINGLY
        //let roles =  profile.appMetadata["roles"]!
        let roles = profile.extraInfo["roles"]!
        //print(roles)
        let displayName = profile.userMetadata["displayName"]!
        //print(displayName)
        if (roles.containsObject("playlist editor") ){
            self.welcomeLabel.text = "Welcome Editor \(displayName)!"
        }

    
    }
    
    private func getPlays(){
        let request = buildAPIRequest("/secured/getPlays", type: "GET")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {/*[unowned self]*/(data, response,
            error) in
            //print(data!)
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            let playsString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(playsString!)
            let playsInt = playsString!.intValue
            
            
            
            //let allSongs = NSString(data: data!, encoding: NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                print("Playlist plays: \(playsInt)")
                self.welcomeLabel.text = "Playlist plays: \(playsInt)"

            })
            
        }
        task.resume()
    }
    
    private func getSongs(){
        let request = buildAPIRequest("/secured/getSongs", type: "GET")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {[unowned self](data, response,
            error) in
            //print(data!)
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            // NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print(dataString!)
            var songArray : [String]
            
            do {
                if let allSongs = try NSJSONSerialization.JSONObjectWithData(data! , options: []) as? NSDictionary{
                    //print("allsongs: ")
                    songArray = allSongs.objectForKey("Songs") as! [String]
                    print(songArray)
                    self.songs = songArray
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            //let allSongs = NSString(data: data!, encoding: NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                // self.songList = "Favorite Genre:  \(songs!)"
                //ADD CELL TO TABLE VIEW
               // print(allSongs)
                
                
                self.songList.beginUpdates()
                for i in 0 ..< self.songs.count{
                    self.songList.insertRowsAtIndexPaths([
                        NSIndexPath(forRow: i, inSection: 0)
                        ], withRowAnimation: .Automatic)
                }
                
                self.songList.endUpdates()
                self.songList.reloadData()
                
            })

        }
        task.resume()
    }

    @IBAction func addSong(sender: AnyObject) {
        //self.welcomeLabel.text = "Added Songs: \(song!)"

        
        let request = buildAPIRequest("/secured/addSong", type: "POST")

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {[unowned self](data, response,
            error) in
            print(data)
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            print("HERE")
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            let addedSong = NSString(data: data!, encoding: NSUTF8StringEncoding)
            dispatch_async(dispatch_get_main_queue(), {
                // code here
               // self.songList = "Favorite Genre:  \(songs!)"
                //ADD CELL TO TABLE VIEW
                print(addedSong!)
                self.songs.append(addedSong! as String)
                self.songList.beginUpdates()
                self.songList.insertRowsAtIndexPaths([
                    NSIndexPath(forRow: self.songs.count-1, inSection: 0)
                    ], withRowAnimation: .Automatic)
                self.songList.endUpdates()
                self.songList.reloadData()
                
            })
            
            
            
        }
        
        task.resume()
    
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertView(title: message, message: nil, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }

    private func buildAPIRequest(path: String, type: String) -> NSURLRequest {
        
        
        let info = NSBundle.mainBundle().infoDictionary!
        let urlString = info["SampleAPIBaseURL"] as! String
        let request = NSMutableURLRequest(URL: NSURL(string: urlString + path)!)
        if (type == "POST")
        {
            //print("IF STATEMENT")
            let song = inputSong.text
            print(song!)
            request.HTTPMethod = "POST"
            //let params = ["song":"\(song)"] as Dictionary<String, String>
            let postString = "song=\(song!)"

            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("text/html", forHTTPHeaderField: "Accept")
            //print(request.HTTPBody)
        }
       

        let keychain = MyApplication.sharedInstance.keychain
        let token = keychain.stringForKey("id_token")!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
