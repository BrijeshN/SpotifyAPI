//
//  ViewController.swift
//  SpotifyAPI
//
//  Created by Brijesh Nayak on 3/1/17.
//  Copyright © 2017 Brijesh Nayak. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

// Player variable that has instance of AVAudioPlayer to allow trakcs to be played
var player = AVAudioPlayer()

// Structs by default have initializer / constructor
struct post {
    
    let mainImage: UIImage!
    let name: String!
    let previewURL: String!
    
}

// Have to implement UISearchBarDelegate to use search bar function
class TableViewController: UITableViewController, UISearchBarDelegate {
    
    // Connecting searchBar to this class to get the text typed in the search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // array of structs
    var posts = [post]()
    
    var searchURL  = String()

    // typealias lets you create your own data type, here JSONStandard is a dictionary
    typealias JSONStandard = [String: AnyObject]
    
    // Perform this action when searchBarButton was clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Get the text entered in the search bar
        let keywords = searchBar.text
        
        // Replace "spaces" with the "+", because that's how spotify api handles the requested url
        let finalkeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        
        // pass the text entered in the search bar to the search url
        searchURL = "https://api.spotify.com/v1/search?q=\(finalkeywords!)&type=track"
        
        // functin call
        callAlamo(url: searchURL)
        
        // Dismiss the keyboard after user presses the SEARCH button on the keyboard
        self.view.endEditing(true)
        
        // remove all the elements so that you can search more than one time
        posts.removeAll()

        
    }
    
    // Reset the text and dismiss the keyboard after user clicks on the CANCEL button in the search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.searchBar.text = ""
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.green]
        
    }

    // function to grab data from the url that you provide
    func callAlamo(url:String) {
        
        // pass the url that calls this function
        Alamofire.request(url).responseJSON(completionHandler: {
            
            // it's gone hold all the data coming from the URL
            response in
            
            // calling parseData function to parse JSON data, and passing all the data that was returned by the url
            self.parseData(JSONData: response.data!)
        })
    }
    
    // Parse JSONData to get specific items
    func parseData(JSONData: Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            
//            print(readableJSON)
            
            if let tracks = readableJSON["tracks"] as? JSONStandard {
                
                if let items = tracks["items"] as? [JSONStandard] {
                    
                    for i in 0..<items.count {
                        
                        let item = items[i]
//                        print(item)
                        let name = item["name"] as! String
                        
                        let previewURL = item["preview_url"] as! String
                        
                        // Get images for the album
                        
                        if let album = item["album"] as? JSONStandard
                        {
                            if let images = album["images"] as? [JSONStandard]
                            {
                                // Images are of different quality high, medium and low
                                // here we are getting images that is of high quality that why we have index 0
                                let imageData = images[0]
                                
                                let mainImageURL = URL(string:imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                
                                let mainImage = UIImage(data: mainImageData as! Data)
                                
                                posts.append(post.init(mainImage: mainImage, name: name, previewURL: previewURL))
                                
                                self.tableView.reloadData()


                            }
                        }
                        
                    }
                    
                }
            }
        } catch {
            print(error)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        //cell?.textLabel?.text = names[indexPath.row]
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = posts[indexPath.row].mainImage
        
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = posts[indexPath.row].name
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! AudioVC
        
        vc.image = posts[indexPath!].mainImage
        vc.mainSongTitle = posts[indexPath!].name
        vc.mainPreviewURL = posts[indexPath!].previewURL
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

