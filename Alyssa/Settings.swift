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
    static let IdentifierForSingleButtonTableCell = "Single Button Table Cell"
    
    // MARK - Identifiers for collection view cells
    static let IdentifierForSingleCharCollectionCell = "Single Char Collection View Cell"
    
    // MARK - Identifiers for segues
    static let IdentifierForSegueToBookContent = "To Book Content"
    static let IdentifierForSegueFromLoginToTabView = "Successfully Login"
    static let IdentifierForSegueToCreateFont = "Present Create Font"
    
    // MARK - Identifiers for storyboards
    static let IdentifierForTabViewController = "Tab Bar Controller"
    static let IdentifierForLoginViewController = "Login View Controller"
    static let IdentifierForTutorialViewController = "Tutorial View Controller ID"
    static let IdentifierForPageViewController = "Universal Page View Controller"
    static let IdentifierForContentViewController = "Tutorial Content View Controller"
    static let IdentifierForHomePageContentViewController = "Home Page Content ID"
    static let IdentifierForBookPageContentViewController = "This is a book page content view"
    static let IdentifierForCustomizedAlertViewController = "Customized Alert View Controller"
    
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
    static let ColorOfAlertView = UIColor(red: 234.0 / 255.0, green: 69.0 / 255.0, blue: 69.0 / 255.0, alpha: 1.0)

    // MARK - Server and API names
    static let ServerIP = "http://52.69.172.155/"
    static let APIFetchingLatestFont = "fetch_latest_font.php"
    static let APICreateNewFont = "alyssa_create_font.php"
    
    // MARK - Keys for UIDefaultUser
    // app related
    static let keyForLatestVersionInDefaultUser = "keyForLatestVersion"
    static let keyForLaunchedBeforeInDefaultUser = "keyForLaunchedBefore"
    
    // user app interaction
    static let keyForHasLoggedInInDefaultUser = "keyForHasLoggedIn"
    static let keyForHasSeenTutorialInDefaultUser = "keyForHasSeenTutorial"
    
    // user account related
    static let keyForNicknameInDefaultUser = "keyForUserNickname"
    
    // font related
    static let keyForActiveFontInDefaultUser = "keyForActiveFont"
    static let keyForFontsLastModifiedTimeInDefaultUser = "keyForFontLastModifiedTime"
    static let keyForFontsFinishedCharsInDefaultUser = "keyForFontFinishedChars"
    
    // home view related
    static let keyForCurrentLevelInDefaultUser = "keyForCurrentLevel"
    
    // book related
    static let keyForUserAddedBooksInDefault = "keyForUserAddedBooks"
    static let keyForCurrentChapterForBooksInDefault = "keyForCurrentChapterOfAllBooks"
    
    // MARK - UI related parameters
    static let widthOfCurrentCharTextFieldNeedingUpdateInStoryboardIfChanged = 40
    static let WidthOfCharGridView = CGFloat(200.0)
    static let AspectRatioOfCharGridView = CGFloat(0.75)
    static let VerticalOffsetOfCharGridView = CGFloat(150)
    
    static let WidthOfCustomizedAlertView = CGFloat(230.0)
    static let HeightOfCustomizedAlertView = CGFloat(50.0)
    static let VerticalOffsetOfCustomizedAlertView = CGFloat(100.0)
    
    static let VerticalOffsetOfCharUnderscore = CGFloat(7.0)
    
    // MARK - System default books
    static let defaultSampleBooks = ["枫桥夜泊","追忆逝水年华","洛丽塔","小王子","gb2312"]
    static let bookNameOfGB2312 = "gb2312"
    static let BookContentSeparationString = "THISISASEPARATIONSTRINGUSEDTOSEPARATECONTENTOFBOOKINTOCHAPTERS\r\n"
    
    // MARK - index for tab view controllers
    static let indexOfCharCaptureViewController = 1
    
    
    // MARK - eraser brush size
    static let minBrushSize = Float(10.0)
    static let maxBrushSize = Float(40.0)
    
    
    static let patternForEmptyString = "^\\s*$"
    
    // MARK - Common functions used by all viewcontroller
    static func fetchDataFromServer(viewController: UIViewController, errMsgForNetwork: String, destinationURL: String, params: NSDictionary, retrivedJSONHandler: (NSDictionary?) -> Void) {
        
        if !Reachability.isConnectedToNetwork() {
            
            // Notify users there's error with network
            popupCustomizedAlert(viewController, message: errMsgForNetwork)
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
                        
                        popupCustomizedAlert(viewController, message: "不好意思，服务器出错了")
                    } else {
                        retrivedJSONHandler(json)
                    }
                }
            })
            
            task.resume()
        }
    }
    
    static func popupCustomizedAlert(viewController: UIViewController, message: String) {
        let customizedAlert = viewController.storyboard?.instantiateViewControllerWithIdentifier(IdentifierForCustomizedAlertViewController) as! CustomizedAlertViewController
        customizedAlert.message = message
        customizedAlert.modalTransitionStyle = .FlipHorizontal
        customizedAlert.modalPresentationStyle = .OverFullScreen
        viewController.presentViewController(customizedAlert, animated: true, completion: nil)
        
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            viewController.dismissViewControllerAnimated(true, completion: nil)
        })
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
    
    static let NumOfCharactersPerLevel = 100
    static let NumOfCharactersPerPage = 20
    
    static func getAllCharsSeparatedBy100PerLevelAnd20PerPage() -> [[String]]{
        var GB2312 : [[String]] = []
        
        let url = NSBundle.mainBundle().URLForResource(self.bookNameOfGB2312, withExtension: "txt")
        do {
            let contentFromGB2312 = try String(contentsOfURL: url!)
            let trimmedContent = contentFromGB2312.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            print(trimmedContent.characters.count)
            
            // MARK - split into levels first
            let splitedForLevels = splitStringToEqualLength(trimmedContent, length: NumOfCharactersPerLevel)
            for s in splitedForLevels {
                let splitedFurtherForPage = splitStringToEqualLength(s, length: NumOfCharactersPerPage)
                GB2312.append(splitedFurtherForPage)
            }
        } catch {
            print(error)
        }
        
        return GB2312
    }
    
    static func splitStringToEqualLength(string: String, length: Int) -> [String] {
        
        var splitedStrings : [String] = []
        
        var index = 0
        let numOfChars = string.characters.count
        while index + length <= numOfChars {
            let stringFromIndexToEnd = string.substringFromIndex(string.startIndex.advancedBy(index))
            let stringFromIndexWithDesiredLength = stringFromIndexToEnd.substringToIndex(stringFromIndexToEnd.startIndex.advancedBy(length))
            splitedStrings.append(stringFromIndexWithDesiredLength)
            index += length
        }
        if index > numOfChars {
            splitedStrings.append(string.substringFromIndex(string.startIndex.advancedBy(index)))
        }
        return splitedStrings
    }
}
