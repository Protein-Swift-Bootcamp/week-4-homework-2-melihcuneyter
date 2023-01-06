//
//  BaseVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 1.01.2023.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension UIViewController {
    func appeareanceUpdate() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = .black

            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

            navigationController?.navigationBar.tintColor = .white
        } else {
            navigationController?.navigationBar.barTintColor = .black
            navigationController?.navigationBar.tintColor = .white
        }
    }
}
