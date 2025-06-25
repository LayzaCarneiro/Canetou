//
//  ContactListTableView.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 24/06/25.
//

import UIKit
import Contacts

class ContactListTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    var contacts: [CNContact] = []
    var didSelectContact: ((CNContact) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    private func setupTableView() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "celula")
        let contact = contacts[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(contact.givenName) \(contact.familyName)"
        if let number = contact.phoneNumbers.first?.value.stringValue {
            content.secondaryText = number
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row]
        didSelectContact?(selectedContact)
    }
}
