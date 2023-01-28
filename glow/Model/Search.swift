//
//  Search.swift
//  glow
//
//  Created by Dreams on 26/07/20.
//  Copyright © 2020 Dreams. All rights reserved.
//

import Foundation
class Search {
    
    var asin: String?
    var price: String?
    var title: String?
    var thumbnail: String?
    var url: String?
    var images: [String]?
   // var sticker: String?

    init(dictionary: [String: Any]) {
        
        self.asin = dictionary["asin"] as? String
        self.price = dictionary["price"] as? String
        self.title = dictionary["title"] as? String
        self.thumbnail = dictionary["thumbnail"] as? String
        self.url = dictionary["url"] as? String
        let tempObj = dictionary["images"] as? [String] ?? []
        self.images = []
        for i in tempObj {
            self.images?.append(i)
        }
        if self.thumbnail == "" || self.thumbnail == nil {
            self.thumbnail = self.images?.first ?? ""
        }
    }
    
    init(asin: String,
         price: String,
         title: String,
         thumbnail: String,
         url: String,
         images: [String])
                  {
        self.asin = asin
        self.price = price
        self.title = title
        self.thumbnail = thumbnail
        self.url = url
        self.images = images
       
    }
    class func getArrayList(array: [[String: Any]]) -> [Search]? {
        var arrayList: [Search] = []
        for obj in array {
            let response = Search(dictionary: obj)
            arrayList.append(response)
        }
        return arrayList
    }
    
    func getDictionary() -> [String:Any] {
        var dictionary: [String:Any] = [:]
        dictionary["asin"] = self.asin
        dictionary["price"] = self.price
        dictionary["title"] = self.title
        dictionary["thumbnail"] = self.thumbnail
        dictionary["url"] = self.url
        dictionary["images"] = self.images
        return dictionary
    }
    
    class func getInstance(dictionary: [String:Any]) -> Search?  {
        let response = Search(dictionary: dictionary)
//        if response. != nil {
            return response
//        }
       // return nil
    }
    
}

class StickersList {
    
    var id: String?
    var url: String?
   
   // var sticker: String?

    init(dictionary: [String: Any]) {
        self.id = dictionary["_id"] as? String
        self.url = dictionary["url"] as? String
    }
    
    init(id: String,
         url: String)
                  {
        self.id = id
        self.url = url
       
    }
    class func getArrayList(array: [[String: Any]]) -> [StickersList]? {
        var arrayList: [StickersList] = []
        for obj in array {
            let response = StickersList(dictionary: obj)
            arrayList.append(response)
        }
        return arrayList
    }
    
    func getDictionary() -> [String:Any] {
        var dictionary: [String:Any] = [:]
        dictionary["_id"] = self.id
        dictionary["url"] = self.url
        return dictionary
    }
    
    class func getInstance(dictionary: [String:Any]) -> StickersList?  {
        let response = StickersList(dictionary: dictionary)
//        if response. != nil {
            return response
//        }
       // return nil
    }
    
}

class ProductSearch {
    
    var ean: String?
    var title: String?
    var description: String?
    var brand: String?
    var mpn: String?
    var color: String?
    var dimension: String?
    var weight: String?
    var category: String?
    var currency: String?
    var lowest_pricing: Int?
    var highest_price: Int?
    var images: [String]?
    var pricing: String?
    

    init(dictionary: [String: Any]) {
        
        self.ean = dictionary["ean"] as? String
        self.title = dictionary["title"] as? String
        self.description = dictionary["description"] as? String
        self.brand = dictionary["brand"] as? String
        self.mpn = dictionary["mpn"] as? String
        self.color = dictionary["color"] as? String
        self.weight = dictionary["weight"] as? String
        self.category = dictionary["category"] as? String
        self.currency = dictionary["currency"] as? String
        self.lowest_pricing = dictionary["lowest_pricing"] as? Int
        self.highest_price = dictionary["highest_price"] as? Int

        let tempObj = dictionary["images"] as? [String] ?? []
        self.images = []
        for i in tempObj {
            self.images?.append(i)
        }

    }
    
    init(ean: String,
         title: String,
         description: String,
         brand: String,
         mpn: String,
         color: String,
         weight: String,
         category: String,
         currency: String,
         lowest_pricing: Int,
         highest_price: Int,
         images: [String])
                  {
        self.ean = ean
        self.title = title
        self.description = description
        self.brand = brand
        self.mpn = mpn
        self.color = color
        self.weight = weight
        self.category = category
        self.currency = currency
        self.lowest_pricing = lowest_pricing
        self.highest_price = highest_price
        self.images = images
    }
    
    class func getInstance(dictionary: [String:Any]) -> ProductSearch?  {
        let response = ProductSearch(dictionary: dictionary)
//        if response. != nil {
            return response
//        }
       // return nil
    }
}

class AxessoSearch {
    
    var asin: String?
    var description: String?
    var imgUrl: String?
    var price: Int?
    var dpUrl: String?

    init(dictionary: [String: Any]) {
        
        self.asin = dictionary["asin"] as? String
        self.description = dictionary["productDescription"] as? String
        self.price = dictionary["price"] as? Int
        self.imgUrl = dictionary["imgUrl"] as? String
        self.dpUrl = dictionary["dpUrl"] as? String
    }
    
    init(asin: String,
         description: String,
         price: Int,
         imgUrl: String,
         dpUrl: String)
                  {
        self.asin = asin
        self.description = description
        self.price = price
        self.imgUrl = imgUrl
        self.dpUrl = dpUrl
    }
    
    class func getArrayList(array: [[String: Any]]) -> [AxessoSearch]? {
        var arrayList: [AxessoSearch] = []
        for obj in array {
            let response = AxessoSearch(dictionary: obj)
            arrayList.append(response)
        }
        return arrayList
    }
    
    func getDictionary() -> [String:Any] {
        var dictionary: [String:Any] = [:]
        dictionary["asin"] = self.asin
        dictionary["price"] = self.price
        dictionary["productDescription"] = self.description
        dictionary["dpUrl"] = self.dpUrl
        dictionary["imgUrl"] = self.imgUrl

        return dictionary
    }
    
    func toSearch() -> Search {
        Search(
            asin: self.asin ?? "",
            price: String(self.price ?? 0),
            title: self.description ?? "",
            thumbnail: self.imgUrl ?? "",
            url: self.dpUrl ?? "",
            images: [self.imgUrl ?? ""])
    }
    
    class func getInstance(dictionary: [String:Any]) -> AxessoSearch?  {
        let response = AxessoSearch(dictionary: dictionary)
//        if response. != nil {
            return response
//        }
       // return nil
    }
    
}

class PriceSearch {
    
    var asin: String?
    var title: String?
    var price: String?
    var imageUrl: String?
    var detailPageURL: String?

    init(dictionary: [String: Any]) {
        
        self.asin = dictionary["ASIN"] as? String
        self.title = dictionary["title"] as? String
        self.price = dictionary["price"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.detailPageURL = dictionary["detailPageURL"] as? String
    }
    
    init(asin: String,
         title: String,
         price: String,
         imageUrl: String,
         detailPageURL: String) {
        self.asin = asin
        self.title = title
        self.price = price
        self.imageUrl = imageUrl
        self.detailPageURL = detailPageURL
    }
    
    class func getArrayList(array: [[String: Any]]) -> [PriceSearch]? {
        var arrayList: [PriceSearch] = []
        for obj in array {
            let response = PriceSearch(dictionary: obj)
            arrayList.append(response)
        }
        return arrayList
    }
    
    func getDictionary() -> [String:Any] {
        var dictionary: [String:Any] = [:]
        dictionary["asin"] = self.asin
        dictionary["title"] = self.title
        dictionary["price"] = self.price
        dictionary["imageUrl"] = self.imageUrl
        dictionary["detailPageURL"] = self.detailPageURL

        return dictionary
    }
    
    func toSearch() -> Search {
        Search(
            asin: self.asin ?? "",
            price: self.price ?? "",
            title: self.title ?? "",
            thumbnail: self.imageUrl ?? "",
            url: self.detailPageURL ?? "",
            images: [self.imageUrl ?? ""])
    }
    
    class func getInstance(dictionary: [String:Any]) -> Search?  {
        let response = Search(dictionary: dictionary)
//        if response. != nil {
            return response
//        }
       // return nil
    }
    
}
