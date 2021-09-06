//
//  RepoModel.swift
//  RxSwift-Multi-Threading-Example
//
//  Created by Huy Trinh Duc on 9/6/21.
//

import Foundation
import ObjectMapper

class RepoModel: Mappable {
    var id: Int?
    var url: String?
    var name: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        url <- map["url"]
        name <- map["name"]
    }
}
