//
//  SettingsViewController.swift
//  EcosystemChallenge
//
//  Created by Hadassa Vitoria on 25/06/25.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground 
        title = "Configurações"

        let label = UILabel()
        label.text = "Conteúdo da Tela de Configurações"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
