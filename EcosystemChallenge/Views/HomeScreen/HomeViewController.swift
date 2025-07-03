//
//  HomeViewController.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 18/06/25.
//

import UIKit
import GroupActivities

class HomeViewController: UIViewController {
    
    let homeView = HomeView()
    var groupSession: GroupSession<DrawTogether>?

    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let session = groupSession, session.state == .joined {
            print("GroupSession está configurada e ativa.")
        } else {
            print("GroupSession ainda não foi configurada ou não está ativa.")
        }

        homeView.settingsButton.addTarget(self, action: #selector(goToSettingsScreen), for: .touchUpInside)
        homeView.nextButton.onTap = { [weak self] in
            self?.goToNextScreen()
            print("Group session:", self?.groupSession)
            
            if let session = self?.groupSession, session.state == .joined {
                print("GroupSession está configurada e ativa.")
            } else {
                print("GroupSession ainda não foi configurada ou não está ativa.")
            }
        }
    }

    @objc func goToNextScreen() {
        let nextScreen = SelectContactViewController()
        nextScreen.onCallAction /*onStartDrawing*/ = { [weak self] in
            self?.navigationController?.pushViewController(WaitingViewController(), animated: true)
        }
        let navController = UINavigationController(rootViewController: nextScreen)
        present(navController, animated: true)
    }
    
    @objc func goToSettingsScreen() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
