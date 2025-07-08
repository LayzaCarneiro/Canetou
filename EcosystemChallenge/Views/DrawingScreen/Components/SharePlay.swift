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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canvasView.becomeFirstResponder()
    }
    
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

    func changeDraw() {
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
        
//        if sessionCount == 2 {
//            sendCurrentDrawing(isFinal: true)
//        }
        
        groupSession.join()
    }
    
    func sendCurrentDrawing(isFinal: Bool = false) {
        guard let messenger = self.messenger else { return }
        let data = canvasView.drawing.dataRepresentation()
        let myID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let message = CanvasMessage(drawingData: data, isFinalDrawing: isFinal, senderID: myID)
        Task {
            try? await messenger.send(message)
        }
//        if isFinal {
            let renderedImage = canvasView.drawing.image(
                from: canvasView.bounds,
                scale: CGFloat(UIScreen.main.scale)
            )
            finalImages.append(renderedImage)
//        }
    }
    
    func handleIncomingDrawing(_ message: CanvasMessage) {
        let myID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"

        // Se for a rodada final, armazena os desenhos
        
        if message.isFinalDrawing && message.senderID != myID {
            do {
                let drawing = try PKDrawing(data: message.drawingData)
                let renderedImage = canvasView.drawing.image(
                    from: canvasView.bounds,
                    scale: CGFloat(UIScreen.main.scale)
                )
                finalImages.append(renderedImage)
                //                let drawing = try PKDrawing(data: message.drawingData)
                //                canvasView.drawing = drawing
                // Ao terminar a segunda rodada, armazena os desenhos
                //                finalDrawings.append(drawing)
            } catch {
                print("Erro ao coletar desenho final: \(error)")
            }
        } else {
            do {
                let drawing = try PKDrawing(data: message.drawingData)
                canvasView.drawing = drawing
            } catch {
                print("Erro ao aplicar desenho recebido: \(error)")
            }
        }
    }
    

    func setupButtonSharePlay() {
        self.button.addTarget(self, action: #selector(connectSharePlay), for: .touchUpInside)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant:  400),
            button.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -140),
            button.widthAnchor.constraint(equalToConstant: 120),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupButtonNext() {
        self.buttonNext.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
        self.view.addSubview(buttonNext)
        buttonNext.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonNext.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant:  400),
            buttonNext.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
            buttonNext.widthAnchor.constraint(equalToConstant: 120),
            buttonNext.heightAnchor.constraint(equalToConstant: 50)
        ])
        sessionCount += 1
    }
    
    @objc func goToNext() {
        navigationController?.pushViewController(
            VerDesenhosViewController(images: finalImages),
            animated: true
        )
    }
    
    @objc func connectSharePlay() {
//        if groupSession == nil && groupStateObserver.isEligibleForGroupSession {
        
        self.startSharing()

//        if sessionCount < 2 {
////                let alert = UIAlertController(
////                    title: "Hora de Trocar os desenhos!",
////                    message: "Agora o desafio é continuar o desenho da outra pessoa!",
////                    preferredStyle: .alert
////                )
////
////                alert.addAction(UIAlertAction(title: "Vamos lá!", style: .default, handler: { [weak self] _ in
////                    guard let self = self else { return }
//
////                    self.startSharing()
//                    self.startConnectSharePlayTimer()
//                    print("🔗 \(Date()) - Executando connectSharePlay!")
//                    self.sessionCount += 1
////                }))
////
////                alert.view.tintColor = UIColor(named: "indigo")
////                present(alert, animated: true, completion: nil)
//
//            } else {
//                sendCurrentDrawing(isFinal: true)
//                stopConnectSharePlayTimer()
//                navigationController?.pushViewController(
//                    VerDesenhosViewController(images: finalImages),
//                    animated: true
//                )
//            }
//        }
    }
    
    @objc private func updateCountdown() {
        if secondsLeft > 0 {
            secondsLeft -= 1
            print("⏳ \(secondsLeft) segundos restantes...")
            print(self.groupSession)
        } else {
            stopConnectSharePlayTimer()
        }
    }
    
    func updateTime() {
        button.setTitle("\(secondsLeft)", for: .normal)
    }
    
    func startConnectSharePlayTimer() {
        connectSharePlayTimer?.invalidate()
        countdownTimer?.invalidate()
        
        secondsLeft = 5
        connectSharePlayTimer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self,
            selector: #selector(connectSharePlay),
            userInfo: nil,
            repeats: true
        )
        
        countdownTimer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCountdown),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopConnectSharePlayTimer() {
        connectSharePlayTimer?.invalidate()
        connectSharePlayTimer = nil

        countdownTimer?.invalidate()
        countdownTimer = nil
        print("⏹️ Timer parado.")

    }
    
    @objc private func accessContacts() {
        let contactsVC = ContactsViewController()
        let navController = UINavigationController(rootViewController: contactsVC)
        present(navController, animated: true, completion: nil)
    }
}
