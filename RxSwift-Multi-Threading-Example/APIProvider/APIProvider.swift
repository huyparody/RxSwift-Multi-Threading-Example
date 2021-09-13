//
//  APIProvider.swift
//  RxSwift-Multi-Threading-Example
//
//  Created by Huy Trinh Duc on 9/6/21.
//

import Foundation
import RxSwift
import UIKit
import Alamofire
import ObjectMapper

class APIProvider {
    
    private let bag = DisposeBag()
    
    func request<H: Mappable>(_ input: APIInputBase) -> Single<[H]> {
        return Single.create { [weak self] single in
            if let self = self {
                Alamofire.Session.default.rx
                    .request(input.requestType,
                             input.url,
                             parameters: input.parameters,
                             encoding: input.encoding,
                             headers: input.headers)
                    .subscribe(on: MainScheduler.instance)
                    .do(onNext: { _ in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    })
                    .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
                    .flatMap { dataRequest in
                        return dataRequest.rx
                            .responseJSON()
                    }
                    .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
                    .map { dataResponse in
                        switch dataResponse.result {
                        case .success(let value):
                            if let dict = value as? [[String: Any]] {
                                let json = Mapper<H>().mapArray(JSONArray: dict)
                                single(.success(json))
                            }
                            else {
                                single(.failure(AFError.explicitlyCancelled))
                            }
                        case .failure(let error):
                            single(.failure(error))
                        }
                    }
                    .observe(on: MainScheduler.instance)
                    .do(onNext: { _ in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                    .subscribe()
                    .disposed(by: self.bag)
            }
            return Disposables.create { 
                Alamofire.Session.default.cancelAllRequests()
            }
        }
    }
    
}
