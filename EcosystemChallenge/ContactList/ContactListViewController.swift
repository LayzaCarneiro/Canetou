////
////  ContactListViewController.swift
////  EcosystemChallenge
////
////  Created by Vinicius Gabriel on 24/06/25.
////
//
//import UIKit
//import Contacts
//
//class ContactListViewController: UIViewController {
//    private let contactsView = ContactListTableView()
//    private let contactList = CNContactStore()
//    
//    override func loadView() {
//        self.view = contactsView
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Contatos"
//    }
//
//    func requestContactsAcess(completion: @escaping (Bool) -> Void) {
//        contactList.requestAccess(for: .contacts) { granted, error in
//            DispatchQueue.main.async {
//                completion(granted)
//            }
//        }
//    }
//    
//    func fetchContacts(completion: @escaping ([CNContact]) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
//            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
//            var contacts: [CNContact] = []
//            
//            do {
//                try self.contactList.enumerateContacts(with: request) { contact, stop in
//                    if !contact.phoneNumbers.isEmpty {
//                        contacts.append(contact)
//                    }
//                }
//            } catch {
//                print("Erro ao buscar contatos: \(error)")
//            }
//            
//            DispatchQueue.main.async {
//                completion(contacts)
//            }
//        }
//    }
//    func startCall(to number: String) {
//        let filteredNumber = number.filter { "0123456789".contains($0) }
//        if let url = URL(string: "facetime://\(filteredNumber)"),
//           UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        } else {
//            print("Não foi possível iniciar a chamada.")
//        }
//    }
//}
