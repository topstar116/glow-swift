//
//  ProductDetailViewController.swift
//  glow
//
//  Created by dhruv dhola on 02/11/20.
//  Copyright © 2020 Dreams. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var amazonButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    var selectedProduct: Videos!
    var selectedVideoList: [Videos] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpUi()
    }
    
    func setUpUi() {
        self.productImageView.contentMode = .scaleAspectFit
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        if let urlString = self.selectedProduct.productThumbnailUrl {
            if let url = URL(string: urlString){
                Utility.showProgress()
                self.productImageView?.sd_setImage(with: url) { (downloadimage, error, type, url) in
                    Utility.dismissProgress()
                    print(error?.localizedDescription ?? "")
                    self.productImageView.image = downloadimage
                }
            }
        }
        self.productNameLabel.text = self.selectedProduct.productName
        self.getReviewProduct()
    }
    
    func getReviewProduct() {
        let param = ["q": "AOC",
                     "page" : 0,
                     "dataPerPage" : 100,
                     "asin": self.selectedProduct.asin ?? ""] as [String : Any]
        UserRequest.getReviewProduct(param: param, filePathKey: []) { (success, videos, error) in
            if error == nil {
                Utility.dismissProgress()
                if videos?.videos != nil {
                    print("success")
                    self.selectedVideoList = videos?.videos ?? []
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.isHidden = true
                    self.noDataLabel.isHidden = false
                    self.noDataLabel.text = "No user reviews yet!"
                }
                
            } else {
                Utility.alert(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func amazonButton(_ sender: UIButton) {
        if let urlString = self.selectedProduct.productUrl {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:]) { (success) in
                    print("open url")
                }
            }
        }
    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "VideoRecordingViewController") as? VideoRecordingViewController {
            let searchData = Search(asin: self.selectedProduct.asin ?? "",
                                    price: "",
                                    title:  self.selectedProduct.productName ?? "",
                                    thumbnail: self.selectedProduct.productThumbnailUrl ?? "",
                                    url: self.selectedProduct.productUrl ?? "",
                                    images: [])
            viewController.searchData = searchData
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "VideoSaveViewController") as? VideoSaveViewController {
            if let url = URL(string: (BASEVIDEOURL) + (self.selectedProduct.videoUrl ?? "")) {
                viewController.videoUrl = url
                viewController.searchProduct = Search(
                    asin: self.selectedProduct.asin ?? "",
                    price: "",
                    title: self.selectedProduct.productName ?? "",
                    thumbnail: self.selectedProduct.productThumbnailUrl ?? "",
                    url: self.selectedProduct.productUrl ?? "",
                    images: [(BASEVIDEOURL) + (self.selectedProduct.thumbnailUrl ?? "")])
            }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @objc func navigation(_ sender : UIButton) {
        let index = sender.tag
        let storyBoard = UIStoryboard(name: "SpotlightDetail", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "SpotlightDetailViewController") as? SpotlightDetailViewController {
            viewController.video = self.selectedVideoList[index]
            viewController.selectedIndex = index
            viewController.videoList = self.selectedVideoList
            let rootVC = UINavigationController(rootViewController: viewController)
            rootVC.setNavigationBarHidden(true, animated: false)
            rootVC.modalPresentationStyle = .fullScreen
            self.present(rootVC, animated: true, completion: nil)
        }
    }

    @objc func productTapped(_ sender : UIButton) {
        let index = sender.tag
        let storyBoard = UIStoryboard(name: "UserScreen", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
            viewController.selectedProduct = self.selectedVideoList[index]
            let rootVC = UINavigationController(rootViewController: viewController)
            rootVC.setNavigationBarHidden(true, animated: false)
            rootVC.modalPresentationStyle = .fullScreen
            self.present(rootVC, animated: true, completion: nil)
        }
    }
}
extension ProductDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedVideoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.titleLabel.text = self.selectedVideoList[indexPath.item].productName
        let urlString = BASE + self.selectedVideoList[indexPath.item].videoUrl!
        if !urlString.isEmpty {
            if let image = Utility.createThumbnailOfVideoFromFileURL(urlString) {
                cell.gifImageView.image = image
            }
        }
        if let stringUrl = self.selectedVideoList[indexPath.item].productThumbnailUrl {
            if let url = URL(string: stringUrl) {
                cell.userImageView.sd_setImage(with: url) { (image, error, type, url) in
                    cell.userImageView.contentMode = .scaleAspectFit
                    cell.userImageView.image = image
                }
            }
        }
        if let userData = self.selectedVideoList[indexPath.item].userId as? [String:Any] {
            let userName = userData["name"] as? String ?? ""
            cell.userNameButton.setTitle(userName, for: .normal)
            if let userpic = userData["profilePic"] as? String {
                if let url = URL(string: BASEVIDEOURL + userpic) {
                    cell.requestButton.sd_setImage(with: url, for: .normal) { (image, error, type, url) in
                        if image != nil {
                            cell.requestButton.setImage(image, for: .normal)
                        } else {
                            cell.requestButton.setImage(UIImage(named: "ic_user"), for: .normal)
                        }
                    }
                }
            }
        }
        
        cell.descLabel.isHidden = true
        cell.navButton.tag = indexPath.item
        cell.navButton.addTarget(self, action: #selector(self.navigation(_:)), for: .touchUpInside)
        cell.productImageButton.tag = indexPath.item
        cell.productImageButton.addTarget(self, action: #selector(self.productTapped(_:)), for: .touchUpInside)
        cell.descLabel.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = 50.0
        let size: CGFloat = collectionView.frame.size.width - CGFloat(padding)
        return CGSize(width: size/2, height: 351)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
