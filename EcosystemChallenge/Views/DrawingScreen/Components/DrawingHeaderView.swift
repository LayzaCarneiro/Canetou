//
//  DrawingHeaderView.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 30/06/25.
//

import UIKit

protocol DrawingHeaderViewDelegate: AnyObject {
    func drawingHeaderTimeDidExpire()
    func didChangeHandPreference(isLeftHanded: Bool)
    func didChangeDarkMode(isDarkMode: Bool)
    func didChangeDrawingTime(seconds: Int)
}

final class DrawingHeaderView: UIView {
    
    // Components
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
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular, scale: .large)
        button.setImage(UIImage(systemName: "gearshape.circle.fill", withConfiguration: largeConfig), for: .normal)
        button.tintColor = .systemGray
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    // Properties
    fileprivate var settingsPopup: UIView?
    fileprivate var isSettingsVisible = false
    weak var delegate: DrawingHeaderViewDelegate?
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var prompts: [String] = []
    private var currentPromptIndex: Int = 0
    
    // Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSettingsButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupSettingsButton()
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
            timerContainer.leadingAnchor.constraint(equalTo: promptContainer.trailingAnchor, constant: 45),
            timerContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            timerContainer.widthAnchor.constraint(equalToConstant: 170),
            timerContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Timer StackView
            timerStackView.centerXAnchor.constraint(equalTo: timerContainer.centerXAnchor),
            timerStackView.centerYAnchor.constraint(equalTo: timerContainer.centerYAnchor)
        ])
    }
    
    private func setupSettingsButton() {
        addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -120),
            settingsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 50),
            settingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        settingsButton.addTarget(self, action: #selector(toggleSettings), for: .touchUpInside)
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
                self.remainingSeconds = 75
                self.startTimer()
            }
        }
    }
    
    private func updateTimeDisplay() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerValueLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Settings Methods
    @objc private func toggleSettings() {
        if isSettingsVisible {
            hideSettings()
        } else {
            showSettings()
        }
        isSettingsVisible.toggle()
    }
    
    private func showSettings() {
        let popup = createSettingsPopup()
        addSubview(popup)
        settingsPopup = popup
        
        // Substitua as constraints atuais por estas:
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: settingsButton.centerXAnchor),
            popup.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 20),
            popup.widthAnchor.constraint(equalToConstant: 200),
            popup.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        popup.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            popup.transform = .identity
            popup.alpha = 1
        }
    }
    
    fileprivate func hideSettings() {
        guard let popup = settingsPopup else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            popup.alpha = 0
        }) { _ in
            popup.removeFromSuperview()
        }
    }
    
    private func createSettingsPopup() -> UIView {
        let popup = UIView()
        popup.backgroundColor = .white
        popup.layer.cornerRadius = 12
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.2
        popup.layer.shadowOffset = CGSize(width: 0, height: 2)
        popup.layer.shadowRadius = 6
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Configuração de mão dominante
        let handControl = createControl(title: "Mão dominante",
                                      options: ["Destro", "Canhoto"],
                                      selectedIndex: 0)
        
        // Configuração de tempo
        let timeControl = createControl(title: "Tempo (seg)",
                                      options: ["30", "60", "120"],
                                      selectedIndex: 2)
        
        stack.addArrangedSubview(handControl)
        stack.addArrangedSubview(timeControl)
        
        popup.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: popup.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -16)
        ])
        
        return popup
    }
    
    private func createControl(title: String, options: [String], selectedIndex: Int) -> UIView {
        let container = UIView()
            
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            
        let segmentedControl = UISegmentedControl(items: options)
        segmentedControl.selectedSegmentIndex = selectedIndex
        segmentedControl.addTarget(self, action: #selector(settingsChanged(_:)), for: .valueChanged)
            
        // Adicione este gesto para fechar ao tocar em qualquer lugar do controle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapControl))
        container.addGestureRecognizer(tapGesture)
            
        container.addSubview(label)
        container.addSubview(segmentedControl)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            segmentedControl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    @objc private func settingsChanged(_ sender: UISegmentedControl) {
        guard let superview = sender.superview,
              let stack = superview.superview as? UIStackView,
              let index = stack.arrangedSubviews.firstIndex(of: superview) else {
            return
        }
        
        switch index {
        case 0:
            delegate?.didChangeHandPreference(isLeftHanded: sender.selectedSegmentIndex == 1)
        case 1:
            delegate?.didChangeDarkMode(isDarkMode: sender.selectedSegmentIndex == 1)
        case 2:
            let times = [30, 60, 120]
            delegate?.didChangeDrawingTime(seconds: times[sender.selectedSegmentIndex])
        default:
            break
        }
        
        hideSettings()
        isSettingsVisible = false
    }
    
    @objc private func didTapControl() {
        hideSettings()
        isSettingsVisible = false
    }
    
    func hideSettingsIfVisible() {
        if isSettingsVisible {
            hideSettings()
            isSettingsVisible = false
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isSettingsVisible, let popup = settingsPopup {
            let popupPoint = convert(point, to: popup)
            return popup.point(inside: popupPoint, with: event) || super.point(inside: point, with: event)
        }
        return super.point(inside: point, with: event)
    }
}

#Preview {
    let header = DrawingHeaderView()
    header.configure(
        prompts: [
            "Desenhe um gato na praia",
        ],
        initialTimeInSeconds: 75
    )
    return header
}
