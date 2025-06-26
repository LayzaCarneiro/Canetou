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
        
        homeView.settingsButton.addTarget(self, action: #selector(goToSettingsScreen), for: .touchUpInside)
        homeView.nextButton.onTap = { [weak self] in
            self?.goToNextScreen()
        }        
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
    
    @objc func goToSettingsScreen() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    func getPrompts() -> [String] {
        let selectedPrompts = prompts.shuffled().prefix(2)
        return Array(selectedPrompts)
    }
}
