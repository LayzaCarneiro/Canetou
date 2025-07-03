//
//  SelectContactView.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 18/06/25.
//

import UIKit
import Contacts
class SelectContactView: UIView, UITextFieldDelegate {
    private let contactsView = UIView()
    private let header = UIView()
    private let explanatoryText = UILabel()
    private let textFieldTitle = UILabel()
    private let textFieldSubtitle = UILabel()
    private let selectContact = UITextField()
    private let openContactListButton = UIButton(type: .contactAdd)
    let callButton = UIButton(type: .system)
    
    let contactListView = ContactListTableView()
    private let contactStore = CNContactStore()
    
    var onAddButtonTapped: (() -> Void)?
    var onCallButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupContactsView()
        setupHeader()
        setupExplanatoryText()
        setupSelectContact()
        setupCallButton()
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
        contactsView.backgroundColor = .lightYellow
        
        NSLayoutConstraint.activate([
            contactsView.topAnchor.constraint(equalTo: topAnchor),
            contactsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contactsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contactsView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupHeader() {
        addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .darkYellow
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contactsView.topAnchor),
            header.leadingAnchor.constraint(equalTo: contactsView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: contactsView.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupExplanatoryText() {
        contactsView.addSubview(explanatoryText)
        contactsView.addSubview(textFieldTitle)
        contactsView.addSubview(textFieldSubtitle)
        
        explanatoryText.translatesAutoresizingMaskIntoConstraints = false
        textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        textFieldSubtitle.translatesAutoresizingMaskIntoConstraints = false
        
        explanatoryText.text = "Ao iniciar a chamada, será redirecionado para o FaceTime.\nAo realizar o convite, volte ao canetou para iniciar o desenho."
        textFieldTitle.text = "Convide um amigo"
        textFieldSubtitle.text = "Para criar uma sala é necessário convidar um amigo através do seu número de telefone."
        
        explanatoryText.textColor = .black
        textFieldTitle.textColor = .gray
        textFieldSubtitle.textColor = .gray
        
        explanatoryText.font = .preferredFont(forTextStyle: .headline)
        textFieldTitle.font = .preferredFont(forTextStyle: .caption1)
        textFieldSubtitle.font = .preferredFont(forTextStyle: .caption1)
        
        explanatoryText.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            explanatoryText.centerYAnchor.constraint(equalTo: header.bottomAnchor, constant: 50),
            explanatoryText.centerXAnchor.constraint(equalTo: contactsView.centerXAnchor),
            explanatoryText.heightAnchor.constraint(equalToConstant: 80),
            
            textFieldTitle.centerYAnchor.constraint(equalTo: explanatoryText.bottomAnchor, constant: 22),
            textFieldTitle.leadingAnchor.constraint(equalTo: contactsView.leadingAnchor, constant: 25),
            
            textFieldSubtitle.centerYAnchor.constraint(equalTo: textFieldTitle.bottomAnchor, constant: 70),
            textFieldSubtitle.leadingAnchor.constraint(equalTo: textFieldTitle.leadingAnchor)
        ])
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
            selectContact.centerYAnchor.constraint(equalTo: header.bottomAnchor, constant: 150),
            selectContact.leadingAnchor.constraint(equalTo: contactsView.leadingAnchor, constant: 16),
            selectContact.trailingAnchor.constraint(equalTo: contactsView.trailingAnchor, constant: -16),
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
        NSLayoutConstraint.activate([
            contactListView.topAnchor.constraint(equalTo: textFieldSubtitle.bottomAnchor, constant: 20),
            contactListView.bottomAnchor.constraint(equalTo: contactsView.bottomAnchor, constant: -120),
            contactListView.leadingAnchor.constraint(equalTo: selectContact.leadingAnchor),
            contactListView.trailingAnchor.constraint(equalTo: selectContact.trailingAnchor)
        ])
    }
    private func setupCallButton() {
        contactsView.addSubview(callButton)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.backgroundColor = .systemPurple
        callButton.setTitle("Iniciar Chamada", for: .normal)
        callButton.setTitleColor(.white, for: .normal)
        callButton.layer.cornerRadius = 10
        callButton.backgroundColor = .indigo
        callButton.titleLabel?.textColor = .white
        callButton.titleLabel?.font = .systemFont(ofSize: 19, weight: .medium)
    
        NSLayoutConstraint.activate([
            callButton.bottomAnchor.constraint(equalTo: contactsView.bottomAnchor, constant: -60),
            callButton.heightAnchor.constraint(equalToConstant: 40),
            callButton.leadingAnchor.constraint(equalTo: selectContact.leadingAnchor),
            callButton.trailingAnchor.constraint(equalTo: selectContact.trailingAnchor)
        ])
        
        callButton.addTarget(self, action: #selector(handleCallButtonTap), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        contactsView.addGestureRecognizer(tapGesture)
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
    
    func fillContactName(_ name: String) {
        selectContact.text = name
    }

    
    @objc private func handleAddContactTap() {
        onAddButtonTapped?()
    }
    
    @objc private func handleCallButtonTap() {
        onCallButtonTapped?()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        contactListView.filterContacts(with: textField.text ?? "")
        
        if !text.isEmpty {
            showContactList()
        }
    }
    
    @objc private func dismissKeyboard() {
        contactsView.endEditing(true)
    }

}

//#Preview {SelectContactView()}
