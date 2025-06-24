//
//  SelectContactViewController.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 23/06/25.
//

import UIKit

class SelectContactViewController: UIViewController {

    let selectContactView = SelectContactView()
    var onStartDrawing: (() -> Void)?

    override func loadView() {
        view = selectContactView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Criar Sala"
        isModalInPresentation = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Desenhar",
            style: .plain,
            target: self,
            action: #selector(createSession)
        )
        
        selectContactView.cancelButton.addTarget(self, action: #selector(dismissContactsView), for: .touchUpInside)
    }

    @objc func dismissContactsView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func createSession() {
        dismiss(animated: true) { [weak self] in
            self?.onStartDrawing?()
        }
    }
}
