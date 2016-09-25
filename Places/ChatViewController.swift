//
//  ChatViewController.swift
//  Places
//
//  Created by Adrian on 25.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var mapViewImage: UIImageView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewImage.image = image
    }
}
