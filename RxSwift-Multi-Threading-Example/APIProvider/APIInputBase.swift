//
//  APIInputBase.swift
//  RxSwift-Multi-Threading-Example
//
//  Created by Huy Trinh Duc on 9/6/21.
//

import Foundation
import Alamofire

struct APIInputBase {
    var headers: HTTPHeaders
    var url: String
    var requestType: HTTPMethod
    var encoding: ParameterEncoding
    var parameters: [String: Any]?
    
    init(url: String, parameters: [String: Any]?, requestType: HTTPMethod, header: HTTPHeaders? = nil) {
        self.url = url
        self.parameters = parameters
        self.requestType = requestType
        self.encoding = requestType == .get ? URLEncoding.default : JSONEncoding.default
        self.headers = header ?? .default
    }
}
