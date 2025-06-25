//
//  SharePlay.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 24/06/25.
//

import UIKit
import GroupActivities
import PencilKit

extension DrawingViewController {
    func startSharing() {
        Task {
            do {
                let activity = DrawTogether(drawingID: "123")
                _ = try await activity.activate()
                
                for await session in DrawTogether.sessions() {
                    configureGroupSession(session)
                }
            } catch {
                print("Failed to activate DrawTogether activity: \(error)")
            }
        }
    }
    
    func configureGroupSession(_ groupSession: GroupSession<DrawTogether>) {
        self.groupSession = groupSession
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                }
            }
            .store(in: &subscriptions)
        groupSession.$state
            .sink { [weak self] state in
                if case .joined = state {
                    self?.sendCurrentDrawing()
                }
            }
            .store(in: &subscriptions)
        groupSession.$activeParticipants
            .sink { [weak self] activeParticipants in
                self?.sendCurrentDrawing()
            }
            .store(in: &subscriptions)
        
        let task = Task {
            for await (message, _) in messenger.messages(of: CanvasMessage.self) {
                self.handleIncomingDrawing(message)
            }
        }
        tasks.insert(task)
        groupSession.join()
    }

    func sendCurrentDrawing() {
        guard let messenger = self.messenger else { return }
        let data = canvasView.drawing.dataRepresentation()
        let message = CanvasMessage(drawingData: data)
        Task {
            try? await messenger.send(message)
        }
    }
    func handleIncomingDrawing(_ message: CanvasMessage) {
        do {
            let drawing = try PKDrawing(data: message.drawingData)
            canvasView.drawing = drawing
        } catch {
            print("Erro ao aplicar desenho recebido: \(error)")
        }
    }
    
    func setupButtonSharePlay() {
        self.button.addTarget(self, action: #selector(connectSharePlay), for: .touchUpInside)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -200),
            button.widthAnchor.constraint(equalToConstant: 120),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupButtonConnectCall() {
        self.buttonCall.addTarget(self, action: #selector(accessContacts), for: .touchUpInside)
        self.view.addSubview(buttonCall)
        buttonCall.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonCall.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            buttonCall.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            buttonCall.widthAnchor.constraint(equalToConstant: 120),
            buttonCall.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func connectSharePlay() {
        if groupSession == nil && groupStateObserver.isEligibleForGroupSession {
            startSharing()
        }
    }
    
    @objc private func accessContacts() {
        let contactsVC = ContactsViewController()
        let navController = UINavigationController(rootViewController: contactsVC)
        present(navController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canvasView.becomeFirstResponder()
    }
}
