//
//  BookPageContentViewController.swift
//  Alyssa
//
//  Created by Wenzheng Li on 1/1/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class BookPageContentViewController: UIViewController {

    @IBOutlet weak var bookContentView: UITextView!
    
    var pageIndex: Int!
    
    var chapterContent: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        if UserProfile.fontFileURL != nil {
            bookContentView.font = UIFont(name: UserProfile.activeFontName!, size: 30)
        } else {
            bookContentView.font = UIFont(name: (bookContentView.font?.fontName)!, size: 20)
        }
        
        bookContentView.editable = false
        bookContentView.text = chapterContent
    }
    
    override func viewWillLayoutSubviews() {
        bookContentView.setContentOffset(CGPointZero, animated: false)
    }
}
