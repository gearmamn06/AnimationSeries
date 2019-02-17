//
//  ViewController.swift
//  AnimationSeries-Demo
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import AnimationSeries



class ViewController: UIViewController {

    @IBOutlet weak var animView: UIView!
    @IBOutlet weak var tableView: UITableView!

    private let types = AnimationExampleType.allCases.filter{ $0 != .none }
    private var currentAnimations = [Recursable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startInitialAnim()
        setUpTableView()
    }

}


/// animation setting
extension ViewController {
    
    private func clearCurrentAnimation() {
        self.currentAnimations.forEach{ $0.clear() }
        self.initializeView()
    }
    
    private func initializeView() {
        animView.transform = CGAffineTransform(rotationAngle: 0)
        animView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        animView.transform = CGAffineTransform(translationX: 0, y: 0)
        animView.alpha = 1.0
        animView.backgroundColor = .red
    }
    
    private func startInitialAnim() {
        let anim = animView.sizing(scale: (40, 40), duration: 0) + animView.sizing(scale: (0.6, 0.6), duration: 1.6, { _ in print("shrink end..") }) + animView.sizing(scale: (1.0, 1.0), duration: 0.3)
        anim.onNext = {
            print("intial animation end...")
        }
        anim.start()
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {

    private func setUpTableView() {
        self.tableView.register(AnimListItemCell.self, forCellReuseIdentifier: AnimListItemCell.name)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnimListItemCell.name) as! AnimListItemCell
        cell.type = self.types[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AnimListItemCell else { return }
        
        clearCurrentAnimation()
        currentAnimations = cell.type.animate(self.animView)
        currentAnimations.forEach { $0.start() }
    }
}

