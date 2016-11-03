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
    
    override func viewWillAppear(_ animated: Bool) {
        var timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    func update()
    {
        print("timer executed once")
        if constants.finishedLoading == true
        {
            dismiss(animated: true, completion: nil)
        }
    }
}
