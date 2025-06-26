//
//  HomeViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 18/06/25.
//

import UIKit

class WaitingViewController: UIViewController {
    
    let waitingView = WaitingView()
    
    override func loadView() {
        view = waitingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waitingView.nextButton.onTap = { [weak self] in
            self?.goToNextScreen()
        }        
    }

    @objc func goToNextScreen() {
        navigationController?.pushViewController(DrawingViewController(), animated: true)
    }
    
    func getPrompts() -> [String] {
        let selectedPrompts = prompts.shuffled().prefix(2)
        return Array(selectedPrompts)
    }
}
