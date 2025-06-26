//
//  SelectContactViewController.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 23/06/25.
//

import UIKit
import Contacts
class SelectContactViewController: UIViewController {

    private let selectContactView = SelectContactView()
    private let contactList = CNContactStore()
    
    var onStartDrawing: (() -> Void)?
    
    override func loadView() {
        view = selectContactView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Criar Sala"
        isModalInPresentation = true

        requestContactsAccess { [weak self] granted in
            guard granted else {
                print("Acesso negado aos contatos.")
                return
            }
            self?.selectContactView.onAddButtonTapped = { [weak self] in
                self?.handleAddContactButton()
            }
//            self?.fetchContacts { contacts in
//                self?.selectContactView.setContacts(contacts)
//                self?.selectContactView.showContactList()
//            }
        }
        selectContactView.setContactSelectionHandler { [weak self] contact in
            self?.handleContactSelection(contact)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Desenhar",
            style: .plain,
            target: self,
            action: #selector(createSession)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancelar",
            style: .plain,
            target: self,
            action: #selector(dismissContactsView)
        )
    }
    
    func requestContactsAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func fetchContacts(completion: @escaping ([CNContact]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]

            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            var contacts: [CNContact] = []

            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    if !contact.phoneNumbers.isEmpty {
                        contacts.append(contact)
                    }
                }
            } catch {
                print("Erro ao buscar contatos: \(error)")
            }

            DispatchQueue.main.async {
                completion(contacts)
            }
        }
    }
    
    func startCall(to number: String) {
        let filteredNumber = number.filter { "0123456789".contains($0) }
        if let url = URL(string: "facetime://\(filteredNumber)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Não foi possível iniciar a chamada.")
        }
    }
    
    private func handleAddContactButton() {
//         requestContactsAccess { [weak self] granted in
//             guard granted else {
//                 print("Acesso negado aos contatos.")
//                 return
//             }
             self.fetchContacts { contacts in
                 self.selectContactView.setContacts(contacts)
                 self.selectContactView.showContactList()
             }
//         }
     }
    
    private func handleContactSelection(_ contact: CNContact) {
        let name = "\(contact.givenName) \(contact.familyName)"
        let number = contact.phoneNumbers.first?.value.stringValue ?? ""
        print("Contato selecionado: \(name) — \(number)")
        
        self.startCall(to: number)
        selectContactView.hideContactList()
    }

    
    @objc func dismissContactsView() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func createSession() {
        dismiss(animated: true) { [weak self] in
            self?.onStartDrawing?()
        }
    }
}
