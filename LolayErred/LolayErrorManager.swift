//  Copyright © 2019 Lolay, Inc.
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

import Foundation

public class LolayErrorManager {
    public weak var delegate: LolayErrorDelegate?
    let bundle: Bundle?
    let tableName: String?
    var showingError: Bool = false

    public init() {
        self.bundle = nil
        self.tableName = nil
    }
    public init(bundle: Bundle, tableName: String?) {
        self.bundle = bundle
        self.tableName = tableName
    }
    
    enum KeyType {
        case localizedTitle
        case localizedDescription
        case recoverySuggestion
        case buttonText
    }
    
    func localizedString(key: String) -> String? {
        if self.delegate != nil {
            return self.delegate!.errorManager(self, localizedStringForKey: key)
        }

        if self.bundle != nil {
            return NSLocalizedString(key, tableName: self.tableName!, bundle: self.bundle!, value: "**" + key + "**", comment: "")
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    func keyForError(_ error: Error, keyType: KeyType) -> String {
        var key = "error-"
        key += String(describing: type(of: error))
        key += "-"
        
        switch keyType {
        case .localizedTitle:
            key += "localizedTitle"
        case .localizedDescription:
            key += "localizedDescription"
        case .recoverySuggestion:
            key += "recoverySuggestion"
        case .buttonText:
            key += "buttonText"
        }
        
        return key
    }
    
    func titleForError(_ error: Error) -> String {
        if self.delegate != nil {
            return self.delegate!.errorManager(self, titleForError: error)
        }
        
        var title: String?
        
        if let localizedError = error as? LocalizedError {
            title = localizedError.errorDescription
        } else {
            let titleKey = keyForError(error, keyType: .localizedTitle)
            title = localizedString(key: titleKey)
        }
        
        if title == nil {
            title = localizedString(key: "error-localizedTitle")
        }
        
        if title == nil {
            title = "Whoops!"
        }
        
        return title!
    }
    
    func messageForError(_ error: Error) -> String? {
        if self.delegate != nil {
            return self.delegate!.errorManager(self, messageForError: error)
        }
        
        var description: String?
        var recoverySuggestion: String?
        
        if let localizedError = error as? LocalizedError {
            description = localizedError.failureReason
            recoverySuggestion = localizedError.recoverySuggestion
        } else {
            let descriptionKey = keyForError(error, keyType: .localizedDescription)
            description = localizedString(key: descriptionKey)
            let recoverySuggestionKey = keyForError(error, keyType: .recoverySuggestion)
            recoverySuggestion = localizedString(key: recoverySuggestionKey)
        }
        
        var message = ""
        if description != nil {
            message += description!
        }
        
        if recoverySuggestion != nil {
            if (message.count > 0) {
                message += "\n"
            }
            
            message += recoverySuggestion!
        }
        
        return message.count > 0 ? message : nil
    }
    
    func buttonTextForError(_ error: Error) -> String {
        if self.delegate != nil {
            return self.delegate!.errorManager(self, buttonTextForError: error)
        }
        
        let buttonKey = keyForError(error, keyType: .buttonText)
        var button = localizedString(key: buttonKey)
        
        if button == nil {
            button = localizedString(key: "error-buttonText")
        }
        
        if button == nil {
            button = "OK"
        }
        
        return button!
    }
    
    func presentError(_ error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                self.presentError(error)
            }
            return
        }
        
        var presentError = true
        if self.delegate != nil {
            presentError = self.delegate!.errorManager(self, shouldPresentError: error)
        }
        guard !presentError else { return }
        
        guard !self.showingError else { return }
        self.showingError = true
        
        let title = titleForError(error)
        let message = messageForError(error)
        let buttonText = buttonTextForError(error)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonText, style: .cancel) { action in
            self.showingError = false
        })
        
        var rootViewController = UIApplication.shared.keyWindow!.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.topViewController
        } else if let tabController = rootViewController as? UITabBarController {
            rootViewController = tabController.selectedViewController
        }
        rootViewController?.present(alertController, animated: true)
        
        if self.delegate != nil {
            self.delegate!.errorManager(self, errorPresented: error)
        }
    }
    
    func presentErrors(_ errors: [Error]) {
        for error in errors {
            presentError(error)
        }
    }
}
