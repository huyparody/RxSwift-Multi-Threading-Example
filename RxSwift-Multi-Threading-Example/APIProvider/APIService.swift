//
//  APIService.swift
//  RxSwift-Multi-Threading-Example
//
//  Created by Huy Trinh Duc on 9/6/21.
//

import Foundation
import RxSwift
import RxAlamofire

class APIService: APIProvider {
    
    static let shared : APIService = {
        let instance = APIService()
        return instance
    }()
    
    func getRepoByUser(_ name: String) -> Observable<[RepoModel]> {
        let url = "https://api.github.com/users/\(name)/repos"
        
        return self.request(.init(url: url, parameters: [:], requestType: .get))
            .asObservable()
            .share()
    }
    
}
