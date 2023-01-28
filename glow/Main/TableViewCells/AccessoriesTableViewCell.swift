//
//  AccessoriesTableViewCell.swift
//  glow
//
//  Created by Dreams on 23/06/20.
//  Copyright © 2020 Dreams. All rights reserved.
//

import UIKit

class AccessoriesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    @IBOutlet weak var accessoriesCollectionView: UICollectionView!
    var spotlightData: [Videos] = []
   
    override func awakeFromNib() {
        super.awakeFromNib()
       
        accessoriesCollectionView.delegate = self
        accessoriesCollectionView.dataSource = self
        
        accessoriesCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func navigation(_ sender : UIButton) {

    }

    @objc func productTapped(_ sender : UIButton) {

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spotlightData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.titleLabel.text = self.spotlightData[indexPath.item].productName
        let urlString = BASE + self.spotlightData[indexPath.item].videoUrl!
        if !urlString.isEmpty {
            if let image = Utility.createThumbnailOfVideoFromFileURL(urlString) {
                cell.gifImageView.image = image
            }
        }
        if let stringUrl = self.spotlightData[indexPath.item].productThumbnailUrl {
            if let url = URL(string: stringUrl) {
                cell.userImageView.sd_setImage(with: url) { (image, error, type, url) in
                    cell.userImageView.contentMode = .scaleAspectFit
                    cell.userImageView.image = image
                }
            }
        }
        if let userData = self.spotlightData[indexPath.item].userId as? [String:Any] {
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
        
        cell.navButton.tag = indexPath.item
        cell.navButton.addTarget(self, action: #selector(self.navigation(_:)), for: .touchUpInside)
        cell.productImageButton.tag = indexPath.item
        cell.productImageButton.addTarget(self, action: #selector(self.productTapped(_:)), for: .touchUpInside)
        cell.descLabel.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       let padding = 50
       let size: CGFloat = collectionView.frame.size.width - CGFloat(padding)
       return CGSize(width: size / 2, height: 351)
    }
    
}
