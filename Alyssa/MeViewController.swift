//
//  MeViewController.swift
//  Alyssa
//
//  Created by Wenzheng Li on 12/24/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = Settings.ColorOfStamp
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Settings.IdentifierForUserInfoTableCell) as! UserInfoTableViewCell
            cell.nickname = UserProfile.userNickname
            cell.email = UserProfile.userEmailAddress
            cell.selectionStyle = .None
            return cell
        }
        
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Settings.IdentifierForSingleButtonTableCell) as! SingleButtonTableViewCell
            if indexPath.row == 0 {
                cell.button.setTitle("更新字体", forState: .Normal)
                cell.button.setTitleColor(Settings.ColorOfStamp, forState: .Normal)
                cell.button.addTarget(self, action: "updateFont", forControlEvents: .TouchUpInside)
            }
            else if indexPath.row == 1 {
                cell.button.setTitle("发送字体到邮箱", forState: .Normal)
                cell.button.setTitleColor(Settings.ColorOfStamp, forState: .Normal)
                cell.button.addTarget(self, action: "emailFont", forControlEvents: .TouchUpInside)
            }
            
            return cell
        }
        
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Settings.IdentifierForSingleLabelTableCell) as! SingleLabelTableViewCell
            if indexPath.row == 0 {
                cell.singleLabel.text = "关于Alyssa"
                cell.selectionStyle = .None
            }
            else if indexPath.row == 1 {
                cell.singleLabel.text = "致谢"
                cell.selectionStyle = .None
            }
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Settings.IdentifierForSingleButtonTableCell) as! SingleButtonTableViewCell
            cell.button.setTitle("退出登录", forState: .Normal)
            cell.button.addTarget(self, action: "logout", forControlEvents: .TouchUpInside)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            performSegueWithIdentifier(Settings.IdentifierForSegueToAboutAlyssa, sender: self)
        }
        else if indexPath.section == 2 && indexPath.row == 1 {
            performSegueWithIdentifier(Settings.IdentifierForSegueToAcknowledgePage, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        if section == 3 {
            return 70
        }
        return 30
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        else if section == 3 {
            return 20
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return 50
        }
    }
    
    func updateFont() {
        Settings.popupCustomizedAlert(self, message: "已经更新到最新版本")
    }
    
    func checkInputs() -> Bool  {
        
        if Settings.isEmpty(UserProfile.userEmailAddress) {
            Settings.popupCustomizedAlert(self, message: "邮箱不能为空")
        } else if !Settings.isValidEmail(UserProfile.userEmailAddress!) {
            Settings.popupCustomizedAlert(self, message: "邮箱地址是无效的")
        } else if Settings.isEmpty(UserProfile.userPassword) {
            Settings.popupCustomizedAlert(self, message: "密码不能为空")
        } else if Settings.isEmpty(UserProfile.activeFontName) {
            Settings.popupCustomizedAlert(self, message: "字体名不能为空")
        } else {
            return true
        }
        return false
    }

    func emailFont() {
        if checkInputs() {
            let params = NSMutableDictionary()
            
            params["email"] = UserProfile.userEmailAddress!
            params["password"] = UserProfile.userPassword!
            params["fontname"] = UserProfile.activeFontName!
            
            let message = "无网络连接"
            Settings.fetchDataFromServer(self, errMsgForNetwork: message, destinationURL: Settings.APIEmailFontToUser, params: params, retrivedJSONHandler: handleEmailFontResponse)
        }
    }
    
    func handleEmailFontResponse (json: NSDictionary?) {
        if let parseJSON = json {
            if let success = parseJSON["success"] as? Bool {
                print("Email font success ",  success)
                if let message = parseJSON["message"] as? String {
                    print("Email font message: ", message)
                    
                    if success {
                        Settings.popupCustomizedAlert(self, message: "字体已发送到邮箱，请查收")
                    } else {
                        Settings.popupCustomizedAlert(self, message: message)
                    }
                }
            }
        }
    }

    func logout() {
        
        UserProfile.hasLoggedIn = false
        UserProfile.userEmailAddress = nil
        UserProfile.userNickname = nil
        UserProfile.userPassword = nil
        UserProfile.activeFontName = nil
        
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        
        let initialViewController = self.storyboard!.instantiateViewControllerWithIdentifier(Settings.IdentifierForLoginViewController)
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
