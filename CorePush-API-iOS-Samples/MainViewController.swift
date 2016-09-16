//
//  ViewController.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit

enum MainCellType: Int {
    case tokenRegister
    case tokenUnregister
    
    func segueIdentifier() -> String {
        switch self {
        case .tokenRegister:
            return "TokenRegister"
        case .tokenUnregister:
            return "TokenUnregister"
        }
    }
    
    func cellName() -> String {
        switch self {
        case .tokenRegister:
            return "トークン登録"
        case .tokenUnregister:
            return "トークン削除"
        }
    }
}

/**
 メイン画面のビューコントローラ
 */
class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ホーム"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: MainCellType(rawValue: (indexPath as NSIndexPath).row)!.segueIdentifier(), sender: nil)
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = MainCellType(rawValue: (indexPath as NSIndexPath).row)?.cellName()
        return cell
    }
}

