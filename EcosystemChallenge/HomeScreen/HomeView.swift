import UIKit

class HomeView: UIView {
    
    let nextButton = UIButton(type: .system)
    let buttonBorder = UIView()
    let settingsButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupButton()
        setupSettingsButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        addSubview(nextButton)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(named: "indigo")
        let font = UIFont.systemFont(ofSize: 27, weight: .medium)
        let attributedTitle = AttributedString("Criar Sala", attributes: AttributeContainer([
                .font: font,
                .foregroundColor: UIColor.white
            ]))
        config.attributedTitle = attributedTitle
        nextButton.configuration = config
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -65),
            nextButton.widthAnchor.constraint(equalToConstant: 315),
            nextButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        nextButton.layer.cornerRadius = 10
        nextButton.clipsToBounds = true
    }
    
    private func setupSettingsButton(){
        addSubview(settingsButton)
        
        let settingsImage = UIImage(named: "settings")
        settingsButton.setImage(settingsImage, for: .normal)
        settingsButton.tintColor = .none
        settingsButton.backgroundColor = .clear
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -20),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 52),
            settingsButton.heightAnchor.constraint(equalToConstant: 52)
                ])
                
//        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
//    }
//    @objc private func settingsTapped() {
//        print("Botão de configurações foi pressionado")
    }
}

#if DEBUG
import SwiftUI

struct GridViewController_Preview: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            HomeViewController()
        }
        .previewDevice("iPad Air 11-inch (M2)")
    }
}

// Adaptador
struct ViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        self.viewController = builder()
    }

    func makeUIViewController(context: Context) -> ViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
#endif
