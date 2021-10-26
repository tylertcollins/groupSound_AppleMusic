//
//  PlaylistInfoView.swift
//  groupSound for Apple Music
//
//  Created by Tyler Collins on 7/26/21.
//

import UIKit

class PlaylistInfoView: UIView {
    
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Playlist Information"
        label.textColor = .white
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .right
        return label
    }()
    
    let inviteRulesetTableView: UITableView = {
        let tableview = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)
        tableview.backgroundColor = .clear
//        tableview.allowsSelection = false
        return tableview
    }()
    
    private let sections: [String] = ["Invite Code", "Playlist Rules", "Options"]
    
    private var inviteCode = "XXXX-XXXX"
    
    private var rulesetModel: [String: String] = [:]
    
    private var rulesetItems: [String] = ["Skip Requirement", "Order Type", "Explicit Tracks", "Minimum Duration", "Maximum Duration", "Repeat Tracks", "Max Contributors", "Max Queue Size", "Max Contributions", "Max Contribution Size"]
    
    public var rulesetID: String? {
        didSet {
            fetchRuleset()
        }
    }
    
    public var deleteButtonHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(infoTitleLabel)
        addSubview(inviteRulesetTableView)
        inviteRulesetTableView.delegate = self
        inviteRulesetTableView.dataSource = self
        inviteRulesetTableView.register(InviteCodeCell.self, forCellReuseIdentifier: "InviteCodeCell")
        inviteRulesetTableView.register(RulesetItemCell.self, forCellReuseIdentifier: "RulesetItemCell")
        inviteRulesetTableView.register(PlaylistOptionsCell.self, forCellReuseIdentifier: "PlaylistOptionsCell")
        
        infoTitleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        inviteRulesetTableView.anchor(top: infoTitleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateInviteCode(code: String) {
        guard let inviteCell = tableView(inviteRulesetTableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? InviteCodeCell else {
            return
        }
        
        self.inviteCode = code
        inviteCell.inviteCode = code
    }
    
    public func fetchRuleset() {
        guard let rulesetID = rulesetID else { return }
        GroupSoundAPI.shared.fetchPlaylistRuleset(forRuleset: rulesetID) { [weak self] results in
            DispatchQueue.main.async {
                switch results {
                case .success(let response):
                    self?.assignRulesetItems(response: response)
                case .failure(let error):
                    print("Error fetching ruleset: \(error)")
                }
            }
        }
    }
    
    private func assignRulesetItems(response: GroupSoundRulesetResponse) {
        if response.skip_type == "percent" { rulesetModel["Skip Requirment"] = "\(response.skips_required)%" }
        else { rulesetModel["Skip Requirement"] = response.skips_required }
        
        if response.order_type == "abc" { rulesetModel["Order Type"] = "ABC" }
        else { rulesetModel["Order Type"] = response.order_type.capitalized }
        
        rulesetModel["Explicit Tracks"] = response.allow_explicit.bool ?? false ? "Allowed" : "Not Allowed"
        
        if let minDuration = Int(response.song_min_duration) {
            if minDuration == 0 { rulesetModel["Minimum Duration"] = "No Limit" }
            else { rulesetModel["Minimum Duration"] = response.song_min_duration }
        } else { rulesetModel["Minimum Duration"] = "Error" }
        
        if let maxDuration = Int(response.song_max_duration) {
            if maxDuration == 99999 { rulesetModel["Maximum Duration"] = "No Limit" }
            else { rulesetModel["Maximum Duration"] = response.song_min_duration }
        } else { rulesetModel["Maximum Duration"] = "Error" }
        
        rulesetModel["Repeat Tracks"] = response.allow_repeats.bool ?? false ? "Allowed" : "Not Allowed"
        rulesetModel["Max Contributors"] = response.max_users
        rulesetModel["Max Queue Size"] = response.max_song_count
        rulesetModel["Max Contributions"] = response.max_user_song_count
        rulesetModel["Max Contribution Size"] = response.max_songs_add
        
        inviteRulesetTableView.reloadData()
    }
    
}

extension PlaylistInfoView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        let label = UILabel()
        label.text = sections[section]
        label.textColor = .white
        label.font = .systemFont(ofSize: 22)
        view.addSubview(label)
        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return rulesetModel.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCodeCell", for: indexPath) as! InviteCodeCell
            cell.inviteCode = inviteCode
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RulesetItemCell", for: indexPath) as! RulesetItemCell
            cell.rulesetItemKey = rulesetItems[indexPath.row]
            cell.rulesetItemValue = rulesetModel[rulesetItems[indexPath.row]] ?? "Error"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistOptionsCell", for: indexPath) as! PlaylistOptionsCell
            cell.deleteButtonHandler = { [weak self] in
                DispatchQueue.main.async {
                    self?.deleteButtonHandler?()
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 90
        case 1:
            return 50
        case 2:
            return 180
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let pasteboard = UIPasteboard.general
            pasteboard.string = inviteCode
        default:
            print("Selected row")
        }
    }
}
