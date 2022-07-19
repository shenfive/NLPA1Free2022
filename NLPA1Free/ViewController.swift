//
//  ViewController.swift
//  NLPA1Free
//
//  Created by 申潤五 on 2022/7/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }


    @IBAction func goTest(_ sender: Any) {
        performSegue(withIdentifier: "goTest", sender: self)
    }
    @IBAction func goInfo(_ sender: Any) {
        performSegue(withIdentifier: "goInfo", sender: self)
    }
}

