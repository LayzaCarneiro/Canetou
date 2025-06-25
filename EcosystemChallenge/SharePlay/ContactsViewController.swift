//
//  ContactsViewController.swift
//  UiKitProject
//
//  Created by Vinicius Gabriel on 17/06/25.
//

import UIKit
import Contacts

class ContactsViewController: UITableViewController {
    var contacts: [CNContact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        requestContactsAccess { granted in
            if granted {
                self.contacts = self.fetchContacts()                
                self.tableView.reloadData()
            } else {
                print("Permissão negada")
            }
        }
    }

    func requestContactsAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func fetchContacts() -> [CNContact] {
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

        return contacts
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        if let number = contact.phoneNumbers.first?.value.stringValue {
            cell.detailTextLabel?.text = number
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        if let number = contact.phoneNumbers.first?.value.stringValue {
            startCall(to: number)
        }
    }

    func startCall(to number: String) {
        if let url = URL(string: "facetime://\(number.filter { "0123456789".contains($0) })"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Não foi possível iniciar a chamada.")
        }
    }
}
