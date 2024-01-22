//
//  Alert++.swift
//  kfd
//
//  Created by mini on 2023/09/14.
//

import UIKit

var controller: UIAlertController?

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            controller?.dismiss(animated: animated)
        }
    }
    func alert(title: String, body: String, withButton: Bool = true) {
        DispatchQueue.main.async {
            controller = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if withButton { controller?.addAction(.init(title: "OK", style: .cancel)) }
            self.present(alert: controller!)
        }
    }
    func dialog(title: String, body: String, onOK: @escaping () -> (), onCancel: @escaping () -> () = {}) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: body, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in onOK() }))
            controller.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in onCancel() }))
            self.present(alert: controller)
        }
    }

    func present(alert: UIAlertController) {
        if let topViewController = topMostViewController() {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
}

func topMostViewController() -> UIViewController? {
    let vc = UIApplication.shared.connectedScenes.filter {
        $0.activationState == .foregroundActive
    }.first(where: { $0 is UIWindowScene })
        .flatMap( { $0 as? UIWindowScene })?.windows
        .first(where: \.isKeyWindow)?
        .rootViewController?
        .topMostViewController()
    return vc
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}
