//
//  MyPageViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit

class MyPageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNicknameDidChange),
            name: .nicknameDidChange,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNicknameDidChange),
            name: .nicknameDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleNicknameDidChange() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension MyPageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MypageSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let mypageSection = MypageSection(rawValue: section) else { return 0 }
        return mypageSection.items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MypageSection(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MypageCell", for: indexPath)

        guard let mypageSection = MypageSection(rawValue: indexPath.section) else { return UITableViewCell() }
        let item = mypageSection.items[indexPath.row]

		cell.textLabel?.text = item.title
        cell.imageView?.image = UIImage(systemName: MypageItem.allCases[indexPath.row].iconName)

        return cell
    }
}

extension MyPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = MypageSection(rawValue: indexPath.section) else { return }

        let item = section.items[indexPath.row]

        switch item {
        case .editNickname:
            let onboardingSB = UIStoryboard(name: "Onboarding", bundle: nil)
            guard let nicknameVC = onboardingSB.instantiateViewController(withIdentifier: "NicknameInputVC") as? NicknameInputViewController else { return }
            nicknameVC.mode = .editing
            navigationController?.pushViewController(nicknameVC, animated: true)
        case .personalSetting:
            let onboardingSB = UIStoryboard(name: "Onboarding", bundle: nil)
            guard let transportVC = onboardingSB.instantiateViewController(withIdentifier: "TransportVC") as? TransportViewController else { return }
            transportVC.mode = .editing
            navigationController?.pushViewController(transportVC, animated: true)
        case .bookmarks:
            print("북마크 페이지 여기서 연결하시면 됩니다.")

        }


    }
}
