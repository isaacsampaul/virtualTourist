//
//  loadingViewController.swift
//  virtualTourist
//
//  Created by Isaac sam paul on 11/3/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import UIKit

class loadingViewController: UIViewController
{
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        constants.progress = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    func update()
    {
        progressView.progress = constants.progress * 0.02
    
        if constants.finishedLoading == true
        {
            dismiss(animated: true, completion: nil)
        }
        if constants.iserror == true
        {
            displayAlert(title: constants.errorTitle, message: constants.errorMessage)

        }
    }
    
    func displayAlert(title: String, message: String)
    {
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        let continueAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
            action in self.dismiss(animated: true, completion: {
                alert.dismiss(animated: true, completion: nil)
            })
            
        }
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
    }
}
