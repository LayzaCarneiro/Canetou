//
//  FinalViewControler.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 24/06/25.
//

import UIKit
import PencilKit

class VerDesenhosViewController: UIViewController {
    
    var finalDrawingsView: FinalDrawingsView
    var drawings: [PKDrawing] = []
    var onEndAction: (() -> Void)?
    
    init(images: [UIImage]) {
        self.finalDrawingsView = FinalDrawingsView(images: images)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = finalDrawingsView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
//        view.backgroundColor = .lightYellow
        view.backgroundColor = .white
        
//        let botaoFinalizar = UIButton(type: .system)
//        botaoFinalizar.setTitle("Finalizar", for: .normal)
//        botaoFinalizar.addTarget(self, action: #selector(finalizar), for: .touchUpInside)
//        botaoFinalizar.translatesAutoresizingMaskIntoConstraints = false
//        
//        let botaoTentarNovamente = UIButton(type: .system)
//        botaoTentarNovamente.setTitle("Tentar novamente", for: .normal)
//        botaoTentarNovamente.addTarget(self, action: #selector(tentarNovamente), for: .touchUpInside)
//        botaoTentarNovamente.translatesAutoresizingMaskIntoConstraints = false
//       
//        view.addSubview(botaoTentarNovamente)
//        view.addSubview(botaoFinalizar)

//        NSLayoutConstraint.activate([
//            botaoFinalizar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            botaoFinalizar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            
//            botaoTentarNovamente.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            botaoTentarNovamente.topAnchor.constraint(equalTo: botaoFinalizar.bottomAnchor, constant: 20)
//        ])
        
        finalDrawingsView.endButton.onTap = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func finalizar() {
        finalDrawingsView.onEndButtonTapped = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func tentarNovamente() {
         if let viewControllers = navigationController?.viewControllers {
             for vc in viewControllers {
                 if vc is DrawingViewController {
                     navigationController?.popToViewController(vc, animated: true)
                     return
                 }
             }
         }

        navigationController?.popViewController(animated: true)
     }
}
