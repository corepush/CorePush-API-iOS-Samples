//
//  HistoryViewController.swift
//  CorePush-API-iOS-Samples
//
//  Copyright © 2016年 BlessService. All rights reserved.
//

import UIKit

/**
    通知履歴画面のビューコントローラ
 */
class HistoryViewController: UIViewController {
    
    // 通知履歴の配列
    var historys = [[String: AnyObject]]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "通知履歴"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // 通知履歴取得のリクエスト
        CorePushHistoryManager.sharedInstance.requestHistory { (historysResponse) in
            if let historysResponse = historysResponse {
                self.historys = historysResponse
                self.tableView.reloadData()
            }
        }
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension HistoryViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let history = historys[indexPath.row]
        
        if let message = history["message"] as? String {
            cell.textLabel?.text = message
        }

        return cell
    }
}
