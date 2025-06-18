import Foundation
import MultipeerConnectivity

@Observable
class LocalNetworkSessionCoordinator: NSObject {
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private let session: MCSession
    
    private(set) var allDevices: Set<MCPeerID> = []
    private(set) var connectedDevices: Set<MCPeerID> = []
    var otherDevices: Set<MCPeerID> {
        return allDevices.subtracting(connectedDevices)
    }
    private(set) var message: String = ""
    
    var receivedImage: UIImage?
    
    init(peerID: MCPeerID = .init(displayName: UIDevice.current.name)) {
        advertiser = .init(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: .messageSendingService
        )
        browser = .init(
            peer: peerID,
            serviceType: .messageSendingService
        )
        session = .init(peer: peerID)
        super.init()
        
        browser.delegate = self
        advertiser.delegate = self
        session.delegate = self
    }
    
    func sendImage(peerID: MCPeerID, image: UIImage) throws {
        if let data = image.pngData() {
            try session.send(data, toPeers: [peerID], with: .reliable)
        }
    }
    
    public func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }
    
    public func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }
    
    public func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    public func stopBrowing() {
        browser.stopBrowsingForPeers()
    }
    
    public func invitePeer(peerID: MCPeerID) {
        browser.invitePeer(
            peerID,
            to: session,
            withContext: nil,
            timeout: 120
        )
    }
    
    public func sendMessage(peerID: MCPeerID, message: String) throws {
        try session.send(
            message.data(using: .utf8)!,
            toPeers: [peerID],
            // .reliable = TCP
            // .unreliable = UDP
            // Remember that we have added two set of configuration on the Info.plist
            // file at the time of configuration. We want guranteed message delivery
            // so we choose TCP/.reliable.
            with: .reliable
        )
    }
}

extension LocalNetworkSessionCoordinator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)
    }
}

extension LocalNetworkSessionCoordinator: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        allDevices.insert(peerID)
    }
    
    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        allDevices.remove(peerID)
    }
    
}

extension LocalNetworkSessionCoordinator: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        DispatchQueue.main.async {
            if let image = UIImage(data: data) {
                // É uma imagem
                self.receivedImage = image
            } else if let text = String(data: data, encoding: .utf8) {
                self.message = text
            }
        }
    }

    
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        if state == .connected {
            connectedDevices.insert(peerID)
        } else {
            connectedDevices.remove(peerID)
        }
    }
    
//    func session(
//        _ session: MCSession,
//        didReceive data: Data,
//        fromPeer peerID: MCPeerID
//    ) {
//        guard let text = String(data: data, encoding: .utf8) else {
//            return
//        }
//        message = "\(text)"
//    }
    
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        
    }
    
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        
    }
    
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {
        
    }
}

private extension String {
    static let messageSendingService = "sendMessage"
}
