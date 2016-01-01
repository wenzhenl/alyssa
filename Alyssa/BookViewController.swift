//
//  ArticleViewController.swift
//  Alyssa
//
//  Created by Wenzheng Li on 12/24/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = Settings.ColorOfStamp
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
    }
    
    var books: [String] {
        return Settings.defaultSampleBooks
    }
    
    @IBAction func updateMyFont(sender: UIBarButtonItem) {
        fetchLatestFont()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Settings.IdentifierForBookTitleCell) as! BookTitleTableViewCell
        cell.bookTitleLabel.text = books[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func fetchLatestFont() {
        
        if UserProfile.userEmailAddress != nil && UserProfile.userPassword != nil && UserProfile.activeFontName != nil {
            
            let params = NSMutableDictionary()
            
            params["userEmailAddress"] = UserProfile.userEmailAddress!
            params["userPassword"] = UserProfile.userPassword!
            params["fontName"] = UserProfile.activeFontName!
            if let lastModifiedTime = getLastModifiedTimeOf(UserProfile.activeFontName!) {
                 params["lastModifiedTime"] = lastModifiedTime
            }
            
            let errInfoForNetwork = "无法更新个人字体信息，请检查你的网络连接"
            
           Settings.fetchDataFromServer(self, errMsgForNetwork: errInfoForNetwork, destinationURL: Settings.APIFetchingLatestFont, params: params, retrivedJSONHandler: handleRetrivedFontData)
        } else {
            Settings.popupAlert(self, title: "无法更新个人字体信息", message: "你还没有创建任何字体")
        }
    }
    
    func handleRetrivedFontData(json: NSDictionary?) {
        if let parseJSON = json {
            
            // Okay, the parsedJSON is here, let's check if the font is still fresh
            if let fresh = parseJSON["fresh"] as? Bool {
                print("Fresh: \(fresh)")
                
                if !fresh {
                    
                    if let fontString = parseJSON["font"] as? String {
                        if let fontData = NSData(base64EncodedString: fontString, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                            if let lastModifiedTime = parseJSON["lastModifiedTime"] as? Double {
                                self.saveFontDataToFileSystem(fontData, lastModifiedTime: lastModifiedTime)
                            }
                        } else {
                            print("Failed convert base64 string to NSData")
                        }
                    } else {
                        print("cannot convert data to String")
                    }
                }
            } else {
                Settings.popupAlert(self, title: "无需更新字体", message: "当前字体已经是最新版本")
            }
        } else {
            print("Cannot fetch data")
        }
    }
    
    func saveFontDataToFileSystem(fontData: NSData, lastModifiedTime: Double) {
        if let fontFileURL = UserProfile.fontFileURL {
            
            if !fontData.writeToURL(fontFileURL, atomically: true) {
                print("Failed to save font", fontFileURL.absoluteString)
            } else {
                print("Successfully saved font ", fontFileURL.absoluteString)
                updateLastModifiedTimeOf(UserProfile.activeFontName!, newTime: lastModifiedTime)
                Settings.updateFont(fontFileURL)
                Settings.popupAlert(self, title: "完成字体更新", message: "成功更新到最新版本")
            }
        }
    }
    
    func getLastModifiedTimeOf(fontName: String) -> Double? {
        if let lastModifiedTimeOfFonts = NSUserDefaults.standardUserDefaults().dictionaryForKey(Settings.keyForFontsLastModifiedTimeInDefaultUser) {
            if let modifiedTime = lastModifiedTimeOfFonts[fontName] {
                return modifiedTime as? Double
            }
        }
        return nil
    }
    
    func updateLastModifiedTimeOf(fontName: String, newTime: Double) {
        
        if let lastModifiedTimeOfFonts = NSUserDefaults.standardUserDefaults().dictionaryForKey(Settings.keyForFontsLastModifiedTimeInDefaultUser) {
            let newLastModifiedTimeOfFonts = NSMutableDictionary(dictionary: lastModifiedTimeOfFonts)
            newLastModifiedTimeOfFonts[fontName] = newTime
            NSUserDefaults.standardUserDefaults().setObject(newLastModifiedTimeOfFonts, forKey: Settings.keyForFontsLastModifiedTimeInDefaultUser)
        } else {
            let newLastModifiedTimeOfFonts = NSMutableDictionary()
            newLastModifiedTimeOfFonts[fontName] = newTime
            NSUserDefaults.standardUserDefaults().setObject(newLastModifiedTimeOfFonts, forKey: Settings.keyForFontsLastModifiedTimeInDefaultUser)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Settings.IdentifierForSegueToBookContent {
                var destination = segue.destinationViewController
                // this next if-statement makes sure the segue prepares properly even
                //   if the MVC we're seguing to is wrapped in a UINavigationController
                if let navCon = destination as? UINavigationController {
                    destination = navCon.visibleViewController!
                }
                if let bcvc = destination as? BookContentViewController {
                    if let bookTitleCell = sender as? BookTitleTableViewCell {
                        bcvc.bookTitle = bookTitleCell.bookTitleLabel.text
                    }
                }
            }
        }
    }
    
}
