//
//  ExchangeDrawingViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 24/06/25.
//

import UIKit

class TrocarDesenhosViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let botaoNovoDesenho = UIButton(type: .system)
        botaoNovoDesenho.setTitle("Novo Desenho", for: .normal)
        botaoNovoDesenho.addTarget(self, action: #selector(abrirNovoDesenho), for: .touchUpInside)
        botaoNovoDesenho.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(botaoNovoDesenho)
        
        NSLayoutConstraint.activate([
            botaoNovoDesenho.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            botaoNovoDesenho.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func abrirNovoDesenho() {
        let novoDesenhoVC = VerDesenhosViewController()
        navigationController?.pushViewController(novoDesenhoVC, animated: true)
    }
}
