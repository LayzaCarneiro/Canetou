//
//  DrawingHeaderView.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 30/06/25.
//

import UIKit

protocol DrawingHeaderViewDelegate: AnyObject {
    func drawingHeaderTimeDidExpire()
}

final class DrawingHeaderView: UIView {
    
    private let promptContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.00, green: 0.89, blue: 0.27, alpha: 1.00)
        view.layer.cornerRadius = 36
        view.layer.masksToBounds = true
        return view
    }()
    
    private let promptLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21, weight: .light)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let timerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 36
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private let timerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    
    private let timerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .light)
        label.textColor = .black
        label.text = "Tempo"
        return label
    }()
    
    private let timerValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 25, weight: .light)
        label.textColor = .black
        return label
    }()
    
    // Properties
    weak var delegate: DrawingHeaderViewDelegate?
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var prompts: [String] = []
    private var currentPromptIndex: Int = 0
    
    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setupView() {
        addSubview(promptContainer)
        promptContainer.addSubview(promptLabel)
        
        addSubview(timerContainer)
        timerStackView.addArrangedSubview(timerTitleLabel)
        timerStackView.addArrangedSubview(timerValueLabel)
        timerContainer.addSubview(timerStackView)
        
        promptContainer.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        timerContainer.translatesAutoresizingMaskIntoConstraints = false
        timerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [promptContainer, promptLabel, timerContainer, timerStackView].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Prompt Container
            promptContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            promptContainer.topAnchor.constraint(equalTo: topAnchor),
            promptContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            promptContainer.widthAnchor.constraint(equalToConstant: 700),
            promptContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Prompt Label
            promptLabel.leadingAnchor.constraint(equalTo: promptContainer.leadingAnchor, constant: 16),
            promptLabel.trailingAnchor.constraint(equalTo: promptContainer.trailingAnchor, constant: -16),
            promptLabel.centerYAnchor.constraint(equalTo: promptContainer.centerYAnchor),
            
            // Timer Container
            timerContainer.leadingAnchor.constraint(equalTo: promptContainer.trailingAnchor, constant: 50),
            timerContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            timerContainer.widthAnchor.constraint(equalToConstant: 220),
            timerContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Timer StackView
            timerStackView.centerXAnchor.constraint(equalTo: timerContainer.centerXAnchor),
            timerStackView.centerYAnchor.constraint(equalTo: timerContainer.centerYAnchor)
        ])
    }
    
    // Public Methods
    func configure(prompts: [String], initialTimeInSeconds: Int) {
        self.prompts = prompts
        self.remainingSeconds = initialTimeInSeconds
        showNextPrompt()
        startTimer()
    }
    
    func updateTime(seconds: Int) {
        remainingSeconds = seconds
        updateTimeDisplay()
    }
    
    // Private Methods
    private func showNextPrompt() {
        guard !prompts.isEmpty else { return }
        promptLabel.text = prompts[currentPromptIndex]
        currentPromptIndex = (currentPromptIndex + 1) % prompts.count
    }
    
    private func startTimer() {
        timer?.invalidate()
        updateTimeDisplay()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.updateTimeDisplay()
            
            if self.remainingSeconds <= 0 {
                self.timer?.invalidate()
                self.delegate?.drawingHeaderTimeDidExpire()
                self.showNextPrompt()
                self.remainingSeconds = 120
                self.startTimer()
            }
        }
    }
    
    private func updateTimeDisplay() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerValueLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let header = DrawingHeaderView()
    header.configure(
        prompts: [
            "Desenhe um gato na praia",
        ],
        initialTimeInSeconds: 120
    )
    return header
}
