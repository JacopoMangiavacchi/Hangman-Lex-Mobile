//
//  BotsLandingViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//

import Foundation
import UIKit
import JSQMessagesViewController

/// The landing screen for showing the list of bots available for Demo.
class BotsLandingViewController: UIViewController {
    
    // List of bots available for demo
    @IBOutlet weak var botsListTableView: UITableView!
    
    fileprivate var bots: [Bot]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        bots = BotsFactory.supportedBots
        botsListTableView.delegate = self
        botsListTableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? BotOperationsViewController {
            destinationViewController.bot = sender as? Bot
        }
    }
}

// MARK: - UITableView Delegate

extension BotsLandingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let showDetailsSegue = "BotShowDetailsSegue"
        performSegue(withIdentifier: showDetailsSegue, sender: bots![indexPath.section])
    }
}

// MARK: - UITableView Data Source

extension BotsLandingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let bots = bots else {return 0}
        return bots.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BotsListTableCell", for: indexPath)
        let bot = bots![indexPath.section]
        cell.textLabel?.text = bot.name
        cell.textLabel?.textColor = UIColor.jsq_messageBubbleBlue()
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}
