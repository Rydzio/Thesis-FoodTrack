//
//  WelcomeViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 02/2/21.
//

import UIKit
import Firebase


class WelcomeViewController: UIViewController {
    
    @IBOutlet weak dynamic var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showTitleAnimation()
        navigationItem.backBarButtonItem?.tintColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)        
    }
    
    func showTitleAnimation() {
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = Constant.appName
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }
    
    @IBAction func unwindSegue( _ seg: UIStoryboardSegue) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
