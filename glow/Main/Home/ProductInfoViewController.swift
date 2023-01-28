//
//  ProductInfoViewController.swift
//  glow
//
//  Created by devStar on 1/10/22.
//  Copyright © 2022 Dreams. All rights reserved.
//

import UIKit

protocol ProductInfoViewControllerDelegate {
    func didPressBack()
}
class ProductInfoViewController: UIViewController {

    // MARK: - Outlet
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var descView: UILabel!
    @IBOutlet weak var segControlView: UISegmentedControl!
    @IBOutlet weak var goButton: UIButton!
    
    // MARK: - Property
    
    var searchProduct: Search?
    var delegate: ProductInfoViewControllerDelegate?
    
    // MARK: - LifeCycle
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backView.layer.cornerRadius = 8.0
        goButton.layer.cornerRadius = 22.0
        
        if let searchData = self.searchProduct {
            let urlString = searchData.images?.first ?? searchData.thumbnail ?? ""
            if let url = URL(string: urlString){
                Utility.showProgress()
                self.thumbnailImageView?.sd_setImage(with: url) { (downloadimage, error, type, url) in
                    Utility.dismissProgress()
                    print(error?.localizedDescription ?? "")
                    self.thumbnailImageView.image = downloadimage
                }
            }

            self.descView.text = "\(searchData.title ?? "")"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    
    @IBAction func onPressGoButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPressBack(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didPressBack()
        }
    }
    
}
