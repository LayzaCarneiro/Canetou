//
//  SelectContactView.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 18/06/25.
//

import UIKit
import Contacts
class SelectContactView: UIView, UITextFieldDelegate {
//    var isContactListVisible = false
    private let contactsView = UIView()
    private let header = UIView()
//    let cancelButton = UIButton(type: .system)
    private let selectContact = UITextField()
    private let openContactListButton = UIButton(type: .contactAdd)
    let contactListView = ContactListTableView()
    private let contactStore = CNContactStore()
    
    var onAddButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupContactsView()
        setupHeader()
        setupSelectContact()
        setupContactListView()
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
        
//        header.addSubview(cancelButton)
//        cancelButton.translatesAutoresizingMaskIntoConstraints = false
//        cancelButton.setTitle("Cancelar", for: .normal)
//        cancelButton.setTitleColor(.systemBlue, for: .normal)
//
//        NSLayoutConstraint.activate([
//            cancelButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
//            cancelButton.centerYAnchor.constraint(equalTo: header.centerYAnchor)
//        ])
    }
    
    private func setupSelectContact() {
        contactsView.addSubview(selectContact)
        contactsView.addSubview(openContactListButton)
        selectContact.translatesAutoresizingMaskIntoConstraints = false
        openContactListButton.translatesAutoresizingMaskIntoConstraints = false
        selectContact.placeholder = "Para:"
        selectContact.borderStyle = .roundedRect
        selectContact.delegate = self
        
        NSLayoutConstraint.activate([
            selectContact.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            selectContact.leadingAnchor.constraint(equalTo: contactsView.leadingAnchor, constant: 20),
            selectContact.trailingAnchor.constraint(equalTo: contactsView.trailingAnchor, constant: -20),
            selectContact.heightAnchor.constraint(equalToConstant: 44),
            
            openContactListButton.topAnchor.constraint(equalToSystemSpacingBelow: selectContact.topAnchor, multiplier: 1),
            openContactListButton.leadingAnchor.constraint(equalToSystemSpacingAfter: selectContact.leadingAnchor, multiplier: 58)
        ])
        selectContact.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        openContactListButton.addTarget(self, action: #selector(handleAddContactTap), for: .touchUpInside)
    }
    
    private func setupContactListView() {
        contactsView.addSubview(contactListView)
        contactListView.translatesAutoresizingMaskIntoConstraints = false
        contactListView.backgroundColor = .systemGray6
        
        NSLayoutConstraint.activate([
            contactListView.topAnchor.constraint(equalToSystemSpacingBelow: selectContact.bottomAnchor, multiplier: 2),
            contactListView.heightAnchor.constraint(equalTo: contactsView.heightAnchor),
            contactListView.leadingAnchor.constraint(equalTo: selectContact.leadingAnchor),
            contactListView.trailingAnchor.constraint(equalTo: selectContact.trailingAnchor)
        ])
    }
    
    func setContacts(_ contacts: [CNContact]) {
        contactListView.updateContacts(contacts)
    }
    
    func setContactSelectionHandler(_ handler: @escaping (CNContact) -> Void) {
        contactListView.didSelectContact = handler
    }
    
    func hideContactList() {
        contactListView.isHidden = true
    }
    
    func showContactList() {
        contactListView.isHidden = false
    }
    
    @objc private func handleAddContactTap() {
        onAddButtonTapped?()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        contactListView.filterContacts(with: textField.text ?? "")
        
        if !text.isEmpty {
            showContactList()
        } else {
            hideContactList()
        }
    }
    
//    @objc private func toggleContactList() {
//        isContactListVisible.toggle()
//        contactListView.isHidden = !isContactListVisible
//    }
}
