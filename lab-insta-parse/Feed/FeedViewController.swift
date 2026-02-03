//  FeedViewController.swift
//  lab-insta-parse
//
//  Created by ritesh kafle
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    private let refreshControl = UIRefreshControl()
    private var limit = 10
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryPosts()
    }

    private func queryPosts() {

        guard !isLoading else { return }
        isLoading = true

        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .limit(limit)

        query.find { [weak self] (result: Result<[Post], ParseError>) in
            guard let self = self else { return }

            self.isLoading = false
            self.refreshControl.endRefreshing()

            switch result {
            case .success(let posts):
                self.posts = posts

            case .failure(let error):
                self.showAlert(description: error.localizedDescription)
            }
        }
    }

    @objc private func refreshFeed() {
        limit = 10
        queryPosts()
    }

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(
            title: "Log out of your account?",
            message: nil,
            preferredStyle: .alert
        )

        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: description ?? "Please try again...",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostCell",
            for: indexPath
        ) as? PostCell else {
            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])
        return cell
    }
}


extension FeedViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        // Load more when user scrolls near bottom
        if position > contentHeight - frameHeight - 100 {
            limit += 10
            queryPosts()
        }
    }
}
