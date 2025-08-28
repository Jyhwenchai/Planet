//
//  ViewController.swift
//  Example
//
//  Created by didong on 2025/8/28.
//

import UIKit
import Planet

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    private let demoItems = [
        DemoItem(title: "基础示例", subtitle: "简单的3D星球视图", viewController: BasicExampleViewController.self),
        DemoItem(title: "技能展示", subtitle: "个人技能星球展示", viewController: SkillExampleViewController.self),
        DemoItem(title: "城市数据", subtitle: "世界主要城市展示", viewController: CityDataViewController.self),
        DemoItem(title: "配置演示", subtitle: "动态调整星球参数", viewController: ConfigurationViewController.self),
        DemoItem(title: "动画效果", subtitle: "各种动画和交互", viewController: AnimationViewController.self)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Planet 示例"
        view.backgroundColor = .systemBackground
        
        // 设置表格视图
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - TableView DataSource & Delegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = demoItems[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = demoItems[indexPath.row]
        let viewController = item.viewController.init()
        viewController.title = item.title
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Demo Item Model

struct DemoItem {
    let title: String
    let subtitle: String
    let viewController: UIViewController.Type
}

