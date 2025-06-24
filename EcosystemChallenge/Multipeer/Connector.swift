//
//  Connector.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 23/06/25.
//

import MultipeerConnectivity

// MARK: - Multipeer Session Manager

class MultipeerSession: NSObject {
    private let serviceType = "pk-draw"

    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser

    var receivedDrawingDataHandler: ((Data) -> Void)?
    
    var connectedPeers: [MCPeerID] = []
    var nearbyPeers: [MCPeerID] = []
    var onPeerListUpdate: (() -> Void)?
    
    private(set) var allDevices: Set<MCPeerID> = []
    private(set) var connectedDevices: Set<MCPeerID> = []
    var otherDevices: Set<MCPeerID> {
        return allDevices.subtracting(connectedDevices)
    }

    override init() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.startAdvertisingPeer()

        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser.startBrowsingForPeers()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)

        super.init()

        browser.delegate = self
        advertiser.delegate = self
        session.delegate = self
    }

    func send(drawingData: Data) {
        if session.connectedPeers.count > 0 {
            do {
                try session.send(drawingData, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Erro enviando dados: \(error)")
            }
        }
    }
}

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            self.onPeerListUpdate?()
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.receivedDrawingDataHandler?(data)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func invitePeer(peerID: MCPeerID) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser.stopBrowsingForPeers()
    }

    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    
    // Detecta peer disponível
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        if peerID != myPeerID && !nearbyPeers.contains(peerID) && !session.connectedPeers.contains(peerID) {
//            nearbyPeers.append(peerID)
//            onPeerListUpdate?()
////            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
//        }
        allDevices.insert(peerID)

    }

    // Remove peer se ele sumir
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = nearbyPeers.firstIndex(of: peerID) {
//            nearbyPeers.remove(at: index)
//            onPeerListUpdate?()
            allDevices.remove(peerID)

        }
    }
    
}
