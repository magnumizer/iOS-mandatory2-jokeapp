//
//  DetailViewController.swift
//  Mandatory2
//
//  Created by Magnus Holm Svendsen on 01/05/2018.
//  Copyright © 2018 Magnus Holm Svendsen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let joke = detailItem {
            if let label = detailDescriptionLabel {
                label.text = joke.content
            }
        } else {
            if let label = detailDescriptionLabel {
                label.text = "Please select a joke."
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Joke? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

