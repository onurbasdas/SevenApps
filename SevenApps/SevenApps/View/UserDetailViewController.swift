//
//  UserDetailViewController.swift
//  SevenApps
//
//  Created by Metin on 18.01.2025.
//

import UIKit

class UserDetailViewController: UIViewController {
    private let viewModel: UserDetailViewModel
    private let stackView = UIStackView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()
    private let websiteLabel = UILabel()
    
    init(viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserDetails()
    }
    
    private func setupUI() {
        title = "User Details"
        view.backgroundColor = .white
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        [nameLabel, emailLabel, phoneLabel, websiteLabel].forEach { label in
            label.numberOfLines = 0
            stackView.addArrangedSubview(label)
        }
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func fetchUserDetails() {
        Task {
            do {
                try await viewModel.fetchUserDetails()
                updateUI()
            } catch {
                // Handle error appropriately
                print("Error fetching user details: \(error)")
            }
        }
    }
    
    private func updateUI() {
        guard let user = viewModel.userDetails else { return }
        nameLabel.text = "Name: \(user.name)"
        emailLabel.text = "Email: \(user.email)"
        phoneLabel.text = "Phone: \(user.phone)"
        websiteLabel.text = "Website: \(user.website)"
    }
}

