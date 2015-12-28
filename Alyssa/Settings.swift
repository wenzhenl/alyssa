//
//  Constants.swift
//  Alyssa
//
//  Created by Wenzheng Li on 10/20/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import Foundation
import UIKit

class Settings {
    
    // MARK - Identifiers for table cells
    static let IdentifierForBookTitleCell = "Book Title Table Cell"
    
    // MARK - Identifiers for segues
    static let IdentifierForSegueToBookContent = "To Book Content"
    
    // MARK - parameters for gestures
    static let GestureScaleForMovingHandwritting = CGFloat(2.0)
    
    // MARK - parameters for color
    static let avaiableHandwrittingColors =
    [   UIColor(red: 1.0, green: 153.0/255.0, blue: 51/255.0, alpha: 1.0),
        UIColor(red: 0, green: 0, blue: 0, alpha: 1.0),
        UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        UIColor(red: 0.0078, green: 0.517647, blue: 0.5098039, alpha: 1.0),
        UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 1.0),
        UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0)
    ]
    
    // MARK - color for header
    static let ColorOfStamp = UIColor(red: 192.0/255.0, green: 0.0/255.0, blue: 14.0/255.0, alpha: 1.0)
    
    // Server and API names
    static let ServerIP = "http://52.69.172.155/"
    static let APIFetchingLatestFont = "fetch_latest_font.php"
    
    static let FontFileName = "FileNameForTest.ttf"
    
    // Keys for UIDefaultUser
    static let keyForFontsLastModifiedTimeInDefaultUser = "keyForFontLastModifiedTime"
    static let keyForLatestVersionInDefaultUser = "keyForLatestVersion"
    static let keyForActiveFontInDefaultUser = "keyForActiveFont"
    
    // Common functions used by all viewcontroller
    static func fetchDataFromServer(viewController: UIViewController, errMsgForNetwork: String, destinationURL: String, params: NSDictionary) -> NSDictionary? {
        
        var retrievedJSON: NSDictionary?
        
        if !Reachability.isConnectedToNetwork() {
            
            // Notify users there's error with network
            let alert = UIAlertController(title: "网络连接错误", message: errMsgForNetwork, preferredStyle: UIAlertControllerStyle.Alert)
            viewController.presentViewController(alert, animated: true, completion: nil)
            
            let delay = 1.5 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
            
        } else {
           
            let url = Settings.ServerIP + destinationURL
            print(url)
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            let session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
            }  catch  {
                print(error)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    var err: NSError?
                    var json:NSDictionary?
                    do{
                        json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    }catch{
                        print(error)
                        err = error as NSError
                    }
                    
                    // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                    if(err != nil) {
                        print("Response: \(response)")
                        let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Body: \(strData!)")
                        print(err!.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                    } else {
                        retrievedJSON = json
                        if retrievedJSON != nil {
                            print("Actually we did get data!")
                        }
                    }
                }
            })
            
            task.resume()
        }
        return retrievedJSON
    }
    
    static func updateFont(fontFileURL: NSURL) {
        let fontData: NSData? = NSData(contentsOfURL: fontFileURL)
        if fontData == nil {
            print("Failed to load saved font:", fontFileURL.absoluteString)
        }
        else {
            var error: Unmanaged<CFError>?
            let provider: CGDataProviderRef = CGDataProviderCreateWithCFData(fontData)!
            let font: CGFontRef = CGFontCreateWithDataProvider(provider)!
            
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                print("Failed to register font, error", error)
            } else {
                print("Successfully registered font", fontFileURL.absoluteString)
            }
        }
    }
}
