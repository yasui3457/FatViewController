//
//  BrowserViewController.swift
//  FatViewController
//
//  Created by 安井陸 on 2019/06/16.
//  Copyright © 2019 安井陸. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeWebView()
    }
    
    func initializeWebView() {
        let request = URLRequest(url: url!)
        webView.load(request)
    }

}

