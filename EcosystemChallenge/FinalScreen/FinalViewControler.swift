//
//  FinalViewControler.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 24/06/25.
//

import UIKit

import UIKit

class VerDesenhosViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        
        let fundoGradiente = FundoGradiente(model: .padrao)
        fundoGradiente.frame = view.bounds
        view.layer.insertSublayer(fundoGradiente, at: 0)
        
        let tituloLabel = UILabel()
        tituloLabel.text = "Os desenhos eram..."
        tituloLabel.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        tituloLabel.textAlignment = .center
        tituloLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tituloLabel)
        
        let retanguloEsquerdo = DesenhoView(model: .padrao)
        let retanguloDireito = DesenhoView(model: .padrao)
        
        view.addSubview(retanguloEsquerdo)
        view.addSubview(retanguloDireito)
        
        let botaoFinalizar = BotaoCustomizado(model: .finalizar)
        let botaoTentarNovamente = BotaoCustomizado(model: .tentarNovamente)
        
        botaoFinalizar.addTarget(self, action: #selector(finalizar), for: .touchUpInside)
        botaoTentarNovamente.addTarget(self, action: #selector(tentarNovamente), for: .touchUpInside)
        
        view.addSubview(botaoFinalizar)
        view.addSubview(botaoTentarNovamente)
        
        NSLayoutConstraint.activate([
            
            tituloLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 64),
            tituloLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 54),
            
            retanguloEsquerdo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 209),
            retanguloDireito.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 209),
            retanguloEsquerdo.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -25),
            retanguloDireito.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 25),
            retanguloDireito.leadingAnchor.constraint(equalTo: retanguloEsquerdo.trailingAnchor, constant: 50),
            
            botaoFinalizar.topAnchor.constraint(equalTo: view.topAnchor, constant: 714),
            botaoFinalizar.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -25),
            botaoTentarNovamente.topAnchor.constraint(equalTo: view.topAnchor, constant: 714),
            botaoTentarNovamente.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 25)
        ])
    }
    
    @objc private func finalizar() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func tentarNovamente() {
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is DesenhoViewController {
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

#Preview {
    VerDesenhosViewController()
}
