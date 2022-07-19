//
//  InfoViewController.swift
//  NLPA1Free
//
//  Created by 申潤五 on 2022/7/19.
//

import UIKit
import WebKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoWeb: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        hindWebBackGround(targateWebView: infoWeb)
        
        infoWeb.isOpaque = false
        infoWeb.backgroundColor = UIColor.clear
        
        for uiview in infoWeb.subviews{
            if uiview.isKind(of: UIImageView.layerClass){
                print("true")
                uiview.isHidden = true
            }
        }
        

        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        infoWeb.load(URLRequest(url: URL(fileReferenceLiteralResourceName: "nlpfreeinfo.html")))

    }

    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
