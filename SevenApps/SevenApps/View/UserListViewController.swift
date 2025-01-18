//
//  UserListViewController.swift
//  SevenApps
//
//  Created by Metin on 18.01.2025.
//

import UIKit

class UserListViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel: UserListViewModel
    
    init(viewModel: UserListViewModel = UserListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "userListView"
        setupUI()
        fetchUsers()
    }
    
    private func setupUI() {
        title = "Users"
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.accessibilityIdentifier = "userListTableView"
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchUsers() {
        Task {
            do {
                try await viewModel.fetchUsers()
                tableView.reloadData()
            } catch {
                // Handle error appropriately
                print("Error fetching users: \(error)")
            }
        }
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfUsers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.accessibilityIdentifier = "userCell_\(indexPath.row)"
        let user = viewModel.user(at: indexPath.row)
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.user(at: indexPath.row)
        let detailViewModel = UserDetailViewModel(userId: user.id)
        let detailVC = UserDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
