//
//  StartViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 23/06/25.
//

import UIKit
import PencilKit
import MultipeerConnectivity

class StartViewController: UIViewController {
    private let multipeerSession = MultipeerSession()
    private let startButton = UIButton(type: .system)
    private let connectionLabel = UILabel()
    private let statusLabel = UILabel()
    
    var prompts: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

//        setupPromptsLabel()

        startButton.setTitle("Start", for: .normal)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.text = "Aguardando conexão..."
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        connectionLabel.textAlignment = .center
        connectionLabel.font = .systemFont(ofSize: 14)
        connectionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(startButton)
        view.addSubview(statusLabel)
        view.addSubview(connectionLabel)

        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            connectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.connectionLabel.text = "Conectado com: \(self?.multipeerSession.connectedPeers.map { $0.displayName }.joined(separator: ", ") ?? "")"
            if self?.multipeerSession.connectedPeers.isEmpty == false {
                self?.startButton.isEnabled = true
            }
        }
    }

    @objc private func startTapped() {
        let drawingVC = DrawingViewController(multipeerSession: multipeerSession)
        navigationController?.pushViewController(drawingVC, animated: true)
    }
    
    func setupPromptsLabel() {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Prompts: \n1. \(prompts[0]) \n2. \(prompts[1])"
        label.textColor = UIColor.black
        label.font = .systemFont(ofSize: 24, weight: .medium)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
            
    ])}
}
