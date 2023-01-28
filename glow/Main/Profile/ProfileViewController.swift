//
//  ProfileViewController.swift
//  glow
//
//  Created by Dreams on 22/06/20.
//  Copyright © 2020 Dreams. All rights reserved.
//

import UIKit
import SDWebImage
import TTSegmentedControl

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileBannerView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var segment: TTSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var infoBackView: UIView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    var selectedVideoList : [Videos] = []
    var videoList: [Videos] = []
    var likedVideos: [Videos] = []
    var products: [MyShelf] = []
    var subscriptions: [User] = []
    var isProduct = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showActionSheet(_:)))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupUI()
        self.getUserVideo()
        self.getUserProfile()
    }
    
    func setupUI() {
        self.profileBannerView.layer.cornerRadius = 36.0
        self.infoBackView.layer.cornerRadius = 32.0
        self.infoBackView.applyDropShadow(color: .black, opacity: 0.5, offset: CGSize(width: 0.5, height: 8.0), radius: 20.0)
        self.isProduct = false
        self.profileImageView.layer.borderWidth = 1.0
        self.profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        if let urlString = Loggdinuser.value(forKey: USERIMAGE) as? String {
            if let url = URL(string: BASE + urlString){
                Utility.showProgress()
                self.profileImageView?.sd_setImage(with: url) { (downloadimage, error, type, url) in
                    Utility.dismissProgress()
                    print(error?.localizedDescription ?? "")
                    self.profileImageView.image = downloadimage
                }
            } else {
                Utility.dismissProgress()
            }
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        // self.shadowView.dropShadow(scale: false)
        self.profileImageView.layer.cornerRadius = 50
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    func setUpSegmentControl() {
        segment.itemTitles = ["Your Reviewed","Like Reviewed","Subscriptions","Save Products"]
        segment.defaultTextColor = UIColor.lightGray
        segment.selectedTextColor = UIColor.black
        segment.thumbGradientColors = [UIColor.clear, UIColor.clear]
        segment.useShadow = false
        segment.backgroundColor = .clear
        segment.didSelectItemWith = { (index,title) -> () in
            if index == 0 {
                self.isProduct = false
//                self.tableView.isHidden = true
                self.collectionView.isHidden = false
                self.noDataLabel.isHidden = true
                self.getUserVideo()
            } else if index == 1 {
                self.isProduct = false
                self.tableView.isHidden = true
                self.collectionView.isHidden = false
                self.noDataLabel.isHidden = true
                self.getLikeVideos()
            } else if index == 2 {
                self.isProduct = false
                self.tableView.isHidden = false
                self.collectionView.isHidden = true
                self.noDataLabel.isHidden = true
                self.getSubscription()
            } else if index == 3 {
                self.tableView.isHidden = true
                self.noDataLabel.isHidden = true
                self.collectionView.isHidden = false
                self.isProduct = true
                self.getProduct()
            }
        }
    }
    
    func getUserProfile() {
        UserRequest.getUser { (success, user, error) in
            if error == nil {
                self.nickNameLabel.text = "@\(user?.userName ?? "")"
                self.usernameLabel.text = user?.name
                self.emailLabel.text = user?.email
            } else {
                Utility.alert(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func getUserVideo() {
        Utility.showProgress()
        UserRequest.userVideos(param: [:], filePathKey: [], imageDataKey: []) { (success, videos, error) in
            Utility.dismissProgress()
            if error == nil {
                if videos?.videos != nil {
                    self.videoList = videos!.videos!
                    if !self.videoList.isEmpty {
//                        self.noDataLabel.isHidden = true
                        self.selectedVideoList = []
                        self.selectedVideoList = self.videoList
                        self.collectionView.reloadData()
                    } else {
                        self.collectionView.isHidden = true
//                        self.noDataLabel.isHidden = false
//                        self.noDataLabel.text = "No user reviews yet!"
                    }
                    
                }
            } else {
                Utility.alert(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func getLikeVideos() {
        Utility.showProgress()
        LikeRequest.getLikeVideos(param: [:]) { (success, response, error) in
            Utility.dismissProgress()
            if error != nil {
                Utility.alert(message: error.debugDescription)
            } else {
                self.likedVideos = response?.videos ?? []
                if !self.likedVideos.isEmpty {
                    self.noDataLabel.isHidden = true
                    self.selectedVideoList = []
                    self.selectedVideoList = self.likedVideos
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.isHidden = true
                    self.noDataLabel.isHidden = false
                    self.noDataLabel.text = "No liked reviews yet!"
                }
            }
        }
    }
    
    
    func getProduct() {
        Utility.showProgress()
        ShelfRequest.getShelfData { (success, response, error) in
            Utility.dismissProgress()
            if error != nil {
                Utility.alert(message: error.debugDescription)
            } else {
                self.products = response ?? []
                if !self.products.isEmpty {
                    self.collectionView.reloadData()
                    self.noDataLabel.isHidden = true
                } else {
                    self.collectionView.isHidden = true
                    self.noDataLabel.isHidden = false
                    self.noDataLabel.text = "No user subscribed yet!"
                }
                
            }
        }
    }
    
    func getSubscription() {
        Utility.showProgress()
        UserRequest.getSubscriptions(param: [:]) { (success, response, error) in
            Utility.dismissProgress()
            if error != nil {
                Utility.alert(message: error.debugDescription)
            } else {
                self.subscriptions = response?.users ?? []
                if !self.subscriptions.isEmpty {
                    self.noDataLabel.isHidden = true
                    self.tableView.reloadData()
                } else {
                    self.noDataLabel.isHidden = false
                    self.tableView.isHidden = true
                    self.noDataLabel.text = "No saved product yet!"
                }
            }
        }
    }
    
    @objc func showActionSheet(_ sender: Any) {
         
    }
    
    @IBAction func profileButton(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func backButton(_ sedner: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editProfile(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
        if let viewController = storyBoard.instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
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

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isProduct {
            return self.products.count
        } else {
            return self.selectedVideoList.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.isProduct {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
            cell.titleLabel.text = self.products[indexPath.item].title
            if let urlString = self.products[indexPath.item].images?.first {
                if let url = URL(string: urlString) {
                    cell.userImageView.sd_setImage(with: url) { (image, error, type, url) in
                        cell.userImageView.image = image
                    }
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
            
            cell.titleLabel.text = self.selectedVideoList[indexPath.item].productName
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
            
            if let stringUrl = self.selectedVideoList[indexPath.item].productThumbnailUrl {
                if let url = URL(string: stringUrl) {
                    cell.userImageView.sd_setImage(with: url) { (image, error, type, url) in
                        cell.userImageView.contentMode = .scaleAspectFit
                        cell.userImageView.image = image
                    }
                }
            }

            if let url = self.self.selectedVideoList[indexPath.item].gif {
                if let urlString = URL(string: BASE + url) {
                    cell.gifImageView.setGifFromURL(urlString)
                }
            }
            
            cell.navButton.tag = indexPath.item
            cell.navButton.addTarget(self, action: #selector(self.navigation(_:)), for: .touchUpInside)
            cell.productImageButton.tag = indexPath.item
            cell.productImageButton.addTarget(self, action: #selector(self.productTapped(_:)), for: .touchUpInside)
            cell.descLabel.isHidden = true
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = 50.0
        let size: CGFloat = collectionView.frame.size.width - CGFloat(padding)
        return CGSize(width: size/2, height: 351)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !self.isProduct {
            let storyBoard = UIStoryboard(name: "Profile", bundle: nil)
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "VideoPlayingViewController") as? VideoPlayingViewController {
                viewController.videoUrl = self.selectedVideoList[indexPath.item].videoUrl ?? ""
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.subscriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeUserTableViewCell", for: indexPath) as! SubscribeUserTableViewCell
        if let urlString = self.subscriptions[indexPath.row].profilePic {
            if let url = URL(string: urlString) {
                cell.userImageView.sd_setImage(with: url) { (image, error, type, url) in
                    cell.userImageView.image = image
                }
            }
        }
        cell.userImageView.layer.cornerRadius = 32.5
        cell.userLabel.text = self.subscriptions[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
