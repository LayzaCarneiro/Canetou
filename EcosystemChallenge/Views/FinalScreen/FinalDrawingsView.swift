//
//  FinalDrawingsView.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 27/06/25.
//

import UIKit

class FinalDrawingsView: UIView {
    let drawingsView = UIStackView()
    private var images: [UIImage]
    private let titleLabel = UILabel()
    private let restartButton = CustomButton(title: "Vamos de novo!")
    private let endButton = CustomButton(title: "Finalizar")
    var onEndButtonTapped: (() -> Void)?
    
    init(images: [UIImage]) {
        self.images = images
        super.init(frame: .zero)
        showDrawings()
        setupTitleText()
//        setupRestartButton()
        setupEndButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    func showDrawings() {
        addSubview(drawingsView)
        drawingsView.axis = .horizontal
        drawingsView.spacing = 8
        drawingsView.alignment = .fill
        drawingsView.distribution = .fillEqually
        drawingsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawingsView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            drawingsView.centerYAnchor.constraint(equalTo: centerYAnchor),
            drawingsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            drawingsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])

        // Loop das imagens existentes para serem exibidas
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            drawingsView.addArrangedSubview(imageView)
        }
    }
    
    func setupTitleText() {
        addSubview(titleLabel)
        titleLabel.text = "Os desenhos eram..."
        titleLabel.textColor = .black
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
        ])
    }
    
//    func setupRestartButton() {
//        addSubview(restartButton)
//        restartButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            restartButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -200),
//            restartButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -65),
//            restartButton.widthAnchor.constraint(equalToConstant: 315),
//            restartButton.heightAnchor.constraint(equalToConstant: 55)
//        ])
//        
//    }
    
    func setupEndButton() {
        addSubview(endButton)
        endButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            endButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            endButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -65),
            endButton.widthAnchor.constraint(equalToConstant: 315),
            endButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    @objc private func handleEndButtonTap() {
        onEndButtonTapped?()
    }
}
#if DEBUG
import SwiftUI

struct FinalDrawingsViewPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> FinalDrawingsView {
        // Aqui você cria algumas imagens de teste
        let dummyImage = UIImage(named: "background")!
        let view = FinalDrawingsView(images: [dummyImage, dummyImage])
        view.backgroundColor = .lightYellow
        return view
    }
    
    func updateUIView(_ uiView: FinalDrawingsView, context: Context) {
        // Aqui você pode atualizar o view se precisar
    }
}

struct FinalDrawingsView_Previews: PreviewProvider {
    static var previews: some View {
        FinalDrawingsViewPreview()
            .previewLayout(.sizeThatFits)
//            .padding()
    }
}
#endif
