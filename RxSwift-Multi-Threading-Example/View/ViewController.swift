//
//  ViewController.swift
//  RxSwift-Multi-Threading-Example
//
//  Created by Huy Trinh Duc on 9/6/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let viewModel = RepoViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search repos of user"
        tableView.register(UINib.init(nibName: "RepoTableViewCell", bundle: nil), forCellReuseIdentifier: "RepoTableViewCell")
        bindViewModel()
    }

    func bindViewModel() {
        
        let input = RepoViewModel.Input(textSearchDidChange: searchBar.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input: input)
        
        output.repo
            .drive(tableView.rx.items) { tableView, index, element in
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepoTableViewCell", for: IndexPath.init(row: index, section: 0)) as! RepoTableViewCell
                cell.textLabel?.text = element.name
                return cell
            }
            .disposed(by: bag)
        
        output.errorMessage
            .drive(onNext: { [weak self] error in
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: bag)
        
    }

}

