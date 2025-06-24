//
//  DrawingViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 23/06/25.
//

import UIKit
import PencilKit
import MultipeerConnectivity

class DrawingViewController: UIViewController {
    private let multipeerSession: MultipeerSession
    private let canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()
    private var timer: Timer?
    private var secondsRemaining = 10
    private let countdownLabel = UILabel()

    init(multipeerSession: MultipeerSession) {
        self.multipeerSession = multipeerSession
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.drawingPolicy = .anyInput
        view.addSubview(canvasView)

        countdownLabel.text = "Tempo: 10s"
        countdownLabel.textAlignment = .center
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownLabel)

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: countdownLabel.topAnchor, constant: -10),

            countdownLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()

        startCountdown()
    }

    private func startCountdown() {
        secondsRemaining = 10
        countdownLabel.text = "Tempo: \(secondsRemaining)s"
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.secondsRemaining -= 1
            self.countdownLabel.text = "Tempo: \(self.secondsRemaining)s"
            if self.secondsRemaining <= 0 {
                timer.invalidate()
                self.goToExchange()
            }
        }
    }

    private func goToExchange() {
        let drawingData = canvasView.drawing.dataRepresentation()
        let exchangeVC = ExchangeViewController(multipeerSession: multipeerSession, myDrawingData: drawingData)
        navigationController?.pushViewController(exchangeVC, animated: true)
    }
}
