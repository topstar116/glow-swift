//
//  SearchResponse.swift
//  glow
//
//  Created by Dreams on 26/07/20.
//  Copyright © 2020 Dreams. All rights reserved.
//

import Foundation
class ProductSearchResponse {
    var status: String?
    var identifier: String?
    var identifierType: String?
    var items: ProductSearch?
    
    init(dictionary: [String: Any]) {
        self.status = dictionary["status"] as? String
        self.identifier = dictionary["identifier"] as? String
        self.identifierType = dictionary["identifier_type"] as? String
        if let obj = dictionary["items"] as? [String: Any] {
            self.items = ProductSearch.getInstance(dictionary: obj)
        }
    }
}

class SearchResponse {
    
    var status: String?
    var data: [Search]?
    var search: Search?
    var msg: String?
    
    init(dictionary: [String: Any]) {
        self.status = dictionary["status"] as? String
//        if let obj = dictionary["data"] as? [[String: Any]] {
//            //self.data = Dashboard.getArrayList(array: obj)
//        }
        if let obj = dictionary["products"] as? [[String: Any]] {
            self.data = Search.getArrayList(array: obj)
        }
        if let obj = dictionary["product"] as? [String: Any] {
            self.search = Search.getInstance(dictionary: obj)
        }
        
        if let obj = dictionary["items"] as? [String: Any] {
            self.search = Search.getInstance(dictionary: obj)
        }

        self.msg = dictionary["msg"] as? String
        self.msg = dictionary["message"] as? String
    }
    
//    class func getInstance(dictionary: [String: Any]) -> LoginResponse? {
//        let response = LoginResponse(dictionary: dictionary)
//        if response.status == "success" {
//            let token = response.access_token
//            Loggdinuser.set(token, forKey: ACCESSTOKEN)
//            return response
//        }
//        return nil
//    }
    
    
}

class StickerResponse {
    
    var status: String?
    var data: [StickersList]?
    var msg: String?
    
    init(dictionary: [String: Any]) {
        self.status = dictionary["status"] as? String
        
        if let obj = dictionary["data"] as? [[String: Any]] {
            self.data = StickersList.getArrayList(array: obj)
        }

        self.msg = dictionary["msg"] as? String
        self.msg = dictionary["message"] as? String
    }

}

class AxessoSearchResponse {
    
    var status: String?
    var data: [AxessoSearch]?
    var msg: String?
    
    init(dictionary: [String: Any]) {
        self.status = dictionary["responseStatus"] as? String

        if let obj = dictionary["searchProductDetails"] as? [[String: Any]] {
            self.data = AxessoSearch.getArrayList(array: obj)
        }
        self.msg = dictionary["responseMessage"] as? String
    }
}

class PriceSearchResponse {
    var data: [PriceSearch]?
    
    init(dictionary: [[String: Any]]) {
        self.data = PriceSearch.getArrayList(array: dictionary)
    }
}
