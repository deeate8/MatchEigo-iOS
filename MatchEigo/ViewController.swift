//
//  ViewController.swift
//  MatchEigo
//
//  Created by Dee Jordan on 21/3/2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func startEmojiGame () {
        let vc = storyboard?.instantiateViewController(identifier: "emojiGame") as! EmojiGameViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}

