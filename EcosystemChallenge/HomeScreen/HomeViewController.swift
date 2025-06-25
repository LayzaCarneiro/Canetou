//
//  HomeViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 18/06/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    let homeView = HomeView()
    
    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        homeView.nextButton.addTarget(self, action: #selector(goToNextScreen), for: .touchUpInside)
    }

    @objc func goToNextScreen() {
        let nextScreen = SelectContactViewController()
        nextScreen.onStartDrawing = { [weak self] in
            let drawingVC = DesenhoViewController()
            self?.navigationController?.pushViewController(drawingVC, animated: true)
        }
        let navController = UINavigationController(rootViewController: nextScreen)
        present(navController, animated: true)
    }
    
    func getPrompts() -> [String] {
        let selectedPrompts = prompts.shuffled().prefix(2)
        return Array(selectedPrompts)
    }
}
