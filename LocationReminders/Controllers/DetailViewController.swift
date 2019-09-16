//
//  DetailViewController.swift
//  LocationReminders
//
//  Created by curtis scott on 12/09/2019.
//  Copyright © 2019 CurtisScott. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = "this page is not finished yet \(detail.note) for  \(detail.address)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var detailItem: LocationNotifacation?


}

