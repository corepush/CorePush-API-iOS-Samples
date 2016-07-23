//
//  ViewController.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit

enum MainCellType: Int {
    case TokenRegister
    case TokenUnregister
    case History
    
    func segueIdentifier() -> String {
        switch self {
        case .TokenRegister:
            return "TokenRegister"
        case .TokenUnregister:
            return "TokenUnregister"
        case .History:
            return "History"
        }
    }
    
    func cellName() -> String {
        switch self {
        case .TokenRegister:
            return "トークン登録"
        case .TokenUnregister:
            return "トークン削除"
        case .History:
            return "通知履歴"
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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier(MainCellType(rawValue: indexPath.row)!.segueIdentifier(), sender: nil)
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = MainCellType(rawValue: indexPath.row)?.cellName()
        return cell
    }
}

