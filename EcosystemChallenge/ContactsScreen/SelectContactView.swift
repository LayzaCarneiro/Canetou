//
//  SelectContactView.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 18/06/25.
//

import UIKit

class SelectContactView: UIView {
    let contactsView = UIView()
    let header = UIView()
    let cancelButton = UIButton(type: .system)
    let selectContact = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupContactsView()
        setupHeader()
        setupSelectContact()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func setupContactsView() {
        addSubview(contactsView)
        
        contactsView.translatesAutoresizingMaskIntoConstraints = false
        contactsView.backgroundColor = .systemBackground
        contactsView.layer.cornerRadius = 13
        contactsView.layer.masksToBounds = true
        contactsView.layoutMargins = .zero
        
        NSLayoutConstraint.activate([
            contactsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contactsView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contactsView.widthAnchor.constraint(equalToConstant: 540),
            contactsView.heightAnchor.constraint(equalToConstant: 620)
        ])
    }
    
    private func setupHeader() {
        contactsView.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .magenta
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contactsView.topAnchor),
            header.leadingAnchor.constraint(equalTo: contactsView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: contactsView.trailingAnchor),
            
            header.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        header.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancelar", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
    }
    
    private func setupSelectContact() {
        contactsView.addSubview(selectContact)
        selectContact.translatesAutoresizingMaskIntoConstraints = false
        selectContact.placeholder = "Para:"
        selectContact.borderStyle = .roundedRect
        
        NSLayoutConstraint.activate([
            selectContact.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            selectContact.leadingAnchor.constraint(equalTo: contactsView.leadingAnchor, constant: 20),
            selectContact.trailingAnchor.constraint(equalTo: contactsView.trailingAnchor, constant: -20),
            selectContact.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
