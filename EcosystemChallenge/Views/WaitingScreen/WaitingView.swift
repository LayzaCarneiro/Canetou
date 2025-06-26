import UIKit

class WaitingView: UIView {
    
    let nextButton = CustomButton(title: "Iniciar Desenho")
    let settingsButton = UIButton(type: .system)
    let backgroundImageView = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        setupNextButton()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNextButton() {
        addSubview(nextButton)
            
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -65),
            nextButton.widthAnchor.constraint(equalToConstant: 315),
            nextButton.heightAnchor.constraint(equalToConstant: 55)
            ])
    }
}
