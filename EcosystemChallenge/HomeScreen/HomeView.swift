//
//  HomeScreen.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 18/06/25.
//

import UIKit

class HomeView: UIView {
    
    let nextButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        addSubview(nextButton)
        
        nextButton.configuration = .filled()
        nextButton.configuration?.baseBackgroundColor = .systemBlue
        nextButton.configuration?.title = "Começar"
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
