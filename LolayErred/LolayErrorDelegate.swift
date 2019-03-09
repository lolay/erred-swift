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

public protocol LolayErrorDelegate: class {
    /// Called before an error is presented. Often used for logging or surpressing presenting an error
    func errorManager(_ errorManager: LolayErrorManager, shouldPresentError error:Error) -> Bool
    /// Called after an error is presented. Often used for logging.
    func errorManager(_ errorManager: LolayErrorManager, errorPresented error:Error)

    /// Ability for an application to override the localizedString for an error
    func errorManager(_ errorManager: LolayErrorManager, localizedStringForKey key: String) -> String?
    /// Ability for an application to override the title for an error
    func errorManager(_ errorManager: LolayErrorManager, titleForError error: Error) -> String
    /// Ability for an application to override the message for an error
    func errorManager(_ errorManager: LolayErrorManager, messageForError error: Error) -> String?
    /// Ability for an application to override the button text for an error
    func errorManager(_ errorManager: LolayErrorManager, buttonTextForError error: Error) -> String
}
