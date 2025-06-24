//
//  ExchangeViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 23/06/25.
//

import UIKit
import PencilKit
import MultipeerConnectivity

class ExchangeViewController: UIViewController {
    private let multipeerSession: MultipeerSession
    private let myDrawingData: Data
    private var hasSent = false
    private var hasReceived = false
    private var receivedData: Data?

    private let statusLabel = UILabel()
    private let exchangeButton = UIButton(type: .system)

    init(multipeerSession: MultipeerSession, myDrawingData: Data) {
        self.multipeerSession = multipeerSession
        self.myDrawingData = myDrawingData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        statusLabel.text = "Clique em Trocar"
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        exchangeButton.setTitle("Trocar", for: .normal)
        exchangeButton.addTarget(self, action: #selector(sendDrawing), for: .touchUpInside)
        exchangeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(statusLabel)
        view.addSubview(exchangeButton)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            exchangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exchangeButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20)
        ])

        multipeerSession.receivedDrawingDataHandler = { [weak self] data in
            guard let self = self else { return }
            self.hasReceived = true
            self.receivedData = data
            self.tryProceedToFinalView()
        }
    }

    @objc private func sendDrawing() {
        multipeerSession.send(drawingData: myDrawingData)
        hasSent = true
        statusLabel.text = "Esperando o outro jogador..."
        exchangeButton.isEnabled = false
        tryProceedToFinalView()
    }

    private func tryProceedToFinalView() {
        if hasSent && hasReceived, let data = receivedData {
            let finalVC = FinalViewController(drawingData: data)
            navigationController?.pushViewController(finalVC, animated: true)
        }
    }
}
