//
//  ContactListTableView.swift
//  EcosystemChallenge
//
//  Created by Vinicius Gabriel on 24/06/25.
//

import UIKit
import Contacts

class ContactListTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var contacts: [CNContact] = []
    var didSelectContact: ((CNContact) -> Void)?
    private var allContacts: [CNContact] = []
    private var filteredContacts: [CNContact] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    func updateContacts(_ newContacts: [CNContact]) {
        self.allContacts = newContacts
        self.filteredContacts = newContacts
        tableView.reloadData()
    }
    
    func filterContacts(with text: String) {
        if text.isEmpty {
            filteredContacts = allContacts
        } else {
            filteredContacts = allContacts.filter {
                let fullName = "\($0.givenName) \($0.familyName)".lowercased()
                return fullName.contains(text.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    private func setupTableView() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "celula")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "celula")
        let contact = filteredContacts[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(contact.givenName) \(contact.familyName)"
        if let number = contact.phoneNumbers.first?.value.stringValue {
            content.secondaryText = number
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = filteredContacts[indexPath.row]
        didSelectContact?(selectedContact)
    }
}
