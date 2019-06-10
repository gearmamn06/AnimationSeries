//
//  RootViewController.swift
//  AnimationSeries-Demo
//
//  Created by ParkHyunsoo on 2019/06/11.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let dest = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            self.navigationController?.pushViewController(dest, animated: true)
        })
    }
}
