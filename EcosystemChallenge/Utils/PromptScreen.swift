//
//  PromptScreen.swift
//  PoC_PromptGeneration
//
//  Created by Layza Maria Rodrigues Carneiro on 16/06/25.
//

import UIKit

class PromptScreen: UIViewController {
    
    var prompts: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupPromptsLabel()
    }
    
    func setupPromptsLabel() {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Prompts: \n1. \(prompts[0]) \n2. \(prompts[1])"
        label.textColor = UIColor.black
        label.font = .systemFont(ofSize: 24, weight: .medium)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
            
    ])}

}
