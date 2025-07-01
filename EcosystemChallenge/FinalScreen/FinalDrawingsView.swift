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
    
    init(images: [UIImage]) {
        self.images = images
        super.init(frame: .zero)
        showDrawings()
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
}
