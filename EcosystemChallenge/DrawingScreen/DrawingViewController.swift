//
//  DrawingViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 24/06/25.
//

import UIKit

class DesenhoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let botaoTrocar = UIButton(type: .system)
        botaoTrocar.setTitle("Trocar Desenhos", for: .normal)
        botaoTrocar.addTarget(self, action: #selector(abrirTrocar), for: .touchUpInside)
        botaoTrocar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(botaoTrocar)
        
        NSLayoutConstraint.activate([
            botaoTrocar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            botaoTrocar.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func abrirTrocar() {
        let trocarVC = TrocarDesenhosViewController()
        navigationController?.pushViewController(trocarVC, animated: true)
    }
}
