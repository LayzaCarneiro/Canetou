//
//  HomeViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 18/06/25.
//

import UIKit
import GroupActivities
import Combine
import PencilKit

class WaitingViewController: UIViewController {
    
    let waitingView = WaitingView()
    
    var playersReady: Set<String> = []
    var hasClickedStart = false

    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<Void, Never>>()
    var groupSession: GroupSession<DrawTogether>?
    var messenger: GroupSessionMessenger?
    var groupStateObserver = GroupStateObserver()
    
    var activityState = false
    
    override func loadView() {
        view = waitingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.playersReady.removeAll()

        startSharing()

        waitingView.nextButton.onTap = { [weak self] in
//            self?.goToNextScreen()
            
            // MARK: Changing view -
            self?.waitingView.backgroundImageView.image = UIImage(named: "waitingImage")
            self?.waitingView.nextButton.removeFromSuperview()
            
            let statusLabel = UILabel()
             statusLabel.text = "Aguardando amigo..."
             statusLabel.font = .systemFont(ofSize: 36, weight: .medium)
             statusLabel.textAlignment = .center
            statusLabel.textColor = .black
             statusLabel.translatesAutoresizingMaskIntoConstraints = false

             self?.waitingView.addSubview(statusLabel)

             NSLayoutConstraint.activate([
                statusLabel.topAnchor.constraint(equalTo: (self?.waitingView.backgroundImageView.bottomAnchor)!, constant: 10),
                statusLabel.centerXAnchor.constraint(equalTo: (self?.waitingView.centerXAnchor)!)
             ])
            
            guard let self = self, let session = self.groupSession else { return }

            self.hasClickedStart = true
            let ownID = session.localParticipant.id.debugDescription
            self.playersReady.insert(ownID)
            
            print("Clicou em Start. Messenger:", self.messenger as Any)
            print("Group session:", self.groupSession)
            
            if self.playersReady.count == session.activeParticipants.count {
                DispatchQueue.main.async {
                    self.goToNextScreen()
                }
            }
            
            Task {
                try? await self.messenger?.send(StartDrawingMessage())
            }
        }

    }
    
    func checkPlayers() {
        guard let session = self.groupSession else { return }

        if self.playersReady.count == session.activeParticipants.count {
            DispatchQueue.main.async {
                self.goToNextScreen()
            }
        }
        
    }

    @objc func goToNextScreen() {
        navigationController?.pushViewController(DrawingViewController(), animated: true)
    }
    
    func getPrompts() -> [String] {
        let selectedPrompts = prompts.shuffled().prefix(2)
        return Array(selectedPrompts)
    }
}

struct StartDrawingMessage: Codable {}

extension WaitingViewController {
    func configureGroupSession(_ session: GroupSession<DrawTogether>) {
        self.groupSession = session
        let messenger = GroupSessionMessenger(session: groupSession!)
        self.messenger = messenger
        
        Task {
            for await (message, context) in messenger.messages(of: StartDrawingMessage.self) {
                self.playersReady.insert(context.source.id.debugDescription)

                if self.hasClickedStart && self.playersReady.count == session.activeParticipants.count {
                    DispatchQueue.main.async {
                        self.goToNextScreen()
                    }

                    self.hasClickedStart = false
//                    self.playersReady.removeAll()
                }
            }
        }

        groupSession!.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                }
            }
            .store(in: &subscriptions)
    
        groupSession?.join()
    }
    
    func startSharing() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        
        let observer = GroupStateObserver()
        
        let task = Task {
            do {
                let activity = DrawTogether(drawingID: "123")
                _ = try await activity.activate()

                for await session in DrawTogether.sessions() {
                    self.groupSession = session
                    configureGroupSession(session)
                }
            } catch {
                print("Erro ao iniciar SharePlay: \(error)")
            }
        }

        tasks.insert(task)
    }

}
