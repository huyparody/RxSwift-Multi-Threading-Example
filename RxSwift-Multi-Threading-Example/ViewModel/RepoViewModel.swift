//
//  RepoViewModel.swift
//  RxSwift-Multi-Threading-Example
//
//  Created by Huy Trinh Duc on 9/6/21.
//

import Foundation
import RxCocoa
import RxSwift

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class RepoViewModel: ViewModelProtocol {
    
    struct Input {
        let textSearchDidChange: Driver<String>
    }
    
    struct Output {
        let repo: Driver<[RepoModel]>
        let errorMessage: Driver<String>
    }
    
    private let bag = DisposeBag()
    private let repoRelay = BehaviorRelay<[RepoModel]>.init(value: [])
    private let errorRelay = PublishRelay<String>()
    
    func transform(input: Input) -> Output {
        
        input.textSearchDidChange
            .asObservable()
            .filter({ [weak self] text in
                if text.count == 0 {
                    self?.repoRelay.accept([])
                    return false
                }
                return true
            })
            .distinctUntilChanged()
            .debounce(.seconds(Int(1.0)), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] name in
                return APIService.shared.getRepoByUser(name)
                    .catch { error in
                        self?.repoRelay.accept([])
                        self?.errorRelay.accept("No repositories for this user.")
                        return Observable.empty()
                    }
            }
            .subscribe { [weak self] repoData in
                if repoData.count == 0 {
                    self?.errorRelay.accept("No repositories for this user.")
                }
                self?.repoRelay.accept(repoData)
            } onError: { [weak self] error in
                self?.repoRelay.accept([])
                self?.errorRelay.accept("No repositories for this user.")
            }
            .disposed(by: bag)

        let repo = repoRelay.asDriver(onErrorJustReturn: [])
        
        let errorMessage = errorRelay.asDriver(onErrorJustReturn: "")
        
        return Output(repo: repo, errorMessage: errorMessage)
    }
    
}
