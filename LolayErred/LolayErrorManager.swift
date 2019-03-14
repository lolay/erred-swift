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
    public let bundle: Bundle?
    public let tableName: String?
    var showingError: Bool = false

    public init() {
        self.bundle = nil
        self.tableName = nil
    }
    public init(bundle: Bundle, tableName: String? = nil) {
        self.bundle = bundle
        self.tableName = tableName
    }
    
    public enum KeyType {
        case localizedTitle
        case localizedDescription
        case recoverySuggestion
        case failureReason
        case buttonText
    }
    
    public func localizedStringForKey(_ key: String, skipDelegate: Bool = false) -> String? {
        if !skipDelegate && self.delegate != nil {
            return self.delegate!.errorManager(self, localizedStringForKey: key)
        }

        var localizedString: String?
        if self.bundle != nil {
            localizedString = NSLocalizedString(key, tableName: self.tableName, bundle: self.bundle!, comment: "")
        } else {
            localizedString = NSLocalizedString(key, comment: "")
        }
        
        return localizedString == key ? nil : localizedString
    }
    
    public func keyForError(_ error: Error, keyType: KeyType) -> String {
        var key = "error-"
        if let lolayError = error as? LolayError {
            key += lolayError.errorKey
        } else {
            key += String(describing: type(of: error))
        }
 
        key += "-"
        
        switch keyType {
        case .localizedTitle:
            key += "localizedTitle"
        case .localizedDescription:
            key += "localizedDescription"
        case .failureReason:
            key += "failureReason"
        case .recoverySuggestion:
            key += "recoverySuggestion"
        case .buttonText:
            key += "buttonText"
        }
        
        return key
    }
    
    public func titleForError(_ error: Error, skipDelegate: Bool = false) -> String {
        if !skipDelegate && self.delegate != nil {
            return self.delegate!.errorManager(self, titleForError: error)
        }
        
        let titleKey = keyForError(error, keyType: .localizedTitle)
        var title: String? = localizedStringForKey(titleKey)

        if title == nil {
            title = localizedStringForKey("error-localizedTitle")
        }
        
        if title == nil {
            title = "Whoops!"
        }
        
        return title!
    }
    
    public func messageForError(_ error: Error, skipDelegate: Bool = false) -> String? {
        if !skipDelegate && self.delegate != nil {
            return self.delegate!.errorManager(self, messageForError: error)
        }
        
        var description: String?
        var failureReason: String?
        var recoverySuggestion: String?
        
        if let localizedError = error as? LocalizedError {
            description = localizedError.errorDescription
            failureReason = localizedError.failureReason
            recoverySuggestion = localizedError.recoverySuggestion
        } else {
            let descriptionKey = keyForError(error, keyType: .localizedDescription)
            description = localizedStringForKey(descriptionKey)
            let failureReasonKey = keyForError(error, keyType: .failureReason)
            failureReason = localizedStringForKey(failureReasonKey)
            let recoverySuggestionKey = keyForError(error, keyType: .recoverySuggestion)
            recoverySuggestion = localizedStringForKey(recoverySuggestionKey)
        }
        
        var message = ""
        if description != nil {
            message += description!
        }
        
        if failureReason != nil {
            if (message.count > 0) {
                message += "\n"
            }
            
            message += failureReason!
        }
        
        if recoverySuggestion != nil {
            if (message.count > 0) {
                message += "\n"
            }
            
            message += recoverySuggestion!
        }
        
        return message.count > 0 ? message : nil
    }
    
    public func buttonTextForError(_ error: Error, skipDelegate: Bool = false) -> String {
        if !skipDelegate && self.delegate != nil {
            return self.delegate!.errorManager(self, buttonTextForError: error)
        }
        
        let buttonKey = keyForError(error, keyType: .buttonText)
        var button = localizedStringForKey(buttonKey)
        
        if button == nil {
            button = localizedStringForKey("error-buttonText")
        }
        
        if button == nil {
            button = "OK"
        }
        
        return button!
    }
    
    public func presentError(_ error: Error) {
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
        guard presentError else { return }
        
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
    
    public func presentErrors(_ errors: [Error]) {
        for error in errors {
            presentError(error)
        }
    }
    
    // MARK: - LolayErrorDelegate
    // Default Implementations
    public func errorManager(_ errorManager: LolayErrorManager, shouldPresentError error: Error) -> Bool {
        return true
    }
    
    public func errorManager(_ errorManager: LolayErrorManager, errorPresented error: Error) { }
    
    public func errorManager(_ errorManager: LolayErrorManager, localizedStringForKey key: String) -> String? {
        return errorManager.localizedStringForKey(key, skipDelegate: true)
    }
    
    public func errorManager(_ errorManager: LolayErrorManager, titleForError error: Error) -> String {
        return errorManager.titleForError(error, skipDelegate: true)
    }
    
    public func errorManager(_ errorManager: LolayErrorManager, messageForError error: Error) -> String? {
        return errorManager.messageForError(error, skipDelegate: true)
    }
    
    public func errorManager(_ errorManager: LolayErrorManager, buttonTextForError error: Error) -> String {
        return errorManager.buttonTextForError(error, skipDelegate: true)
    }
}
