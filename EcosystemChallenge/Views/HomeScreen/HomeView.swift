import UIKit

class HomeView: UIView {
    
    let nextButton = CustomButton(title: "Criar Sala")
    let settingsButton = UIButton(type: .system)
    let backgroundImageView = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupBackgroundImageView()
        setupNextButton()
        setupSettingsButton()
        
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
    
    private func setupSettingsButton(){
        addSubview(settingsButton)
        
        let settingsImage = UIImage(named: "settings")
        settingsButton.setImage(settingsImage, for: .normal)
        settingsButton.tintColor = .none
        settingsButton.backgroundColor = .clear
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -15),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 52),
            settingsButton.heightAnchor.constraint(equalToConstant: 52)
                ])
        settingsButton.clipsToBounds = true
                
    }
    
    private func setupBackgroundImageView() {
        addSubview(backgroundImageView)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        sendSubviewToBack(backgroundImageView)
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
