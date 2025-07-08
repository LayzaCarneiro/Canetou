import UIKit
import Combine
import GroupActivities
import PencilKit

class WaitingView: UIView {
    
    let nextButton = CustomButton(title: "Iniciar Desenho")
    let settingsButton = UIButton(type: .system)
    let backgroundImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(named: "yellowBackground")
        setupBackgroundImageView()
        setupNextButton()
        setupButtonAction()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNextButton() {
        addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 315),
            nextButton.heightAnchor.constraint(equalToConstant: 55)
            ])
    }
    
    private func setupBackgroundImageView() {
        addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.image = UIImage(named: "startDrawImage")

        NSLayoutConstraint.activate([
            backgroundImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            backgroundImageView.widthAnchor.constraint(equalToConstant: 370),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 370)
        ])
    }
    
    private func setupButtonAction() {
        nextButton.onTap = { [weak self] in
            self?.backgroundImageView.image = UIImage(named: "waitingImage")
        }
    }
}
