//
//  PeersView.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 23/06/25.
//

import UIKit
import PencilKit
import MultipeerConnectivity

class PeersViewController: UITableViewController {
    private let localNetwork = MultipeerSession()

    enum Section: Int, CaseIterable {
        case connected
        case nearby

        var title: String {
            switch self {
            case .connected: return "Connected"
            case .nearby: return "Nearby"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "P2P"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        localNetwork.onPeerListUpdate = { [weak self] in
            self?.tableView.reloadData()
        }

        localNetwork.startBrowsing()
        localNetwork.startAdvertising()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .connected: return localNetwork.connectedPeers.count
        case .nearby: return localNetwork.nearbyPeers.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var peer: MCPeerID

        switch Section(rawValue: indexPath.section)! {
        case .connected:
            peer = localNetwork.connectedPeers[indexPath.row]
            cell.textLabel?.text = peer.displayName
            cell.accessoryType = .checkmark
            cell.accessoryView = nil
        case .nearby:
            peer = localNetwork.nearbyPeers[indexPath.row]
            cell.textLabel?.text = peer.displayName

            let inviteButton = UIButton(type: .contactAdd)
            inviteButton.addAction(UIAction { [weak self] _ in
                self?.localNetwork.invitePeer(peerID: peer)
            }, for: .touchUpInside)
            cell.accessoryView = inviteButton
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .connected else { return }

        let peer = localNetwork.connectedPeers[indexPath.row]
        let vc = DrawingViewController(multipeerSession: MultipeerSession())
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        localNetwork.stopBrowsing()
        localNetwork.stopAdvertising()
    }
}
