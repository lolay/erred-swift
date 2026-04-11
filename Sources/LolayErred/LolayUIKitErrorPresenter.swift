//  Copyright © 2019, 2023, 2026 Lolay, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if canImport(UIKit)
import UIKit

@MainActor
public class LolayUIKitErrorPresenter: LolayErrorPresenter {
    public init() {}

    public func present(title: String, message: String?, buttonText: String, onDismiss: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonText, style: .cancel) { _ in
            onDismiss?()
        })

        let topViewController = self.topViewController()
        topViewController.present(alertController, animated: true)
    }

    func topViewController() -> UIViewController {
        let controller = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first!.rootViewController
        assert(controller != nil, "App doesn't have a rootViewController yet!")
        return self.topViewController(controller: controller!)
    }

    func topViewController(controller: UIViewController) -> UIViewController {
        var nextController: UIViewController?

        if let navigationController = controller as? UINavigationController {
            nextController = navigationController.topViewController
        } else if let tabController = controller as? UITabBarController {
            nextController = tabController.selectedViewController
        } else if let presentedController = controller.presentedViewController {
            nextController = presentedController
        }

        if let recurseController = nextController {
            return self.topViewController(controller: recurseController)
        }

        return controller
    }
}
#endif
