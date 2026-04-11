//  Copyright © 2019, 2023 Lolay, Inc.
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

import Testing
import Foundation
@testable import LolayErred

struct TestLocalizedError: LocalizedError {
    let errorDescription: String?
    let failureReason: String?
    let recoverySuggestion: String?

    init(errorDescription: String, failureReason: String, recoverySuggestion: String) {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
        self.recoverySuggestion = recoverySuggestion
    }
}

enum EnumError: String, Error, LolayError {
    case firstEnum

    var errorKey: String {
        get {
            return String(describing: type(of: self)) + "." + self.rawValue
        }
    }
}

@MainActor
final class PassthroughDelegate: LolayErrorDelegate {
    func errorManager(_ errorManager: LolayErrorManager, shouldPresentError error: Error) -> Bool {
        return true
    }

    func errorManager(_ errorManager: LolayErrorManager, errorPresented error: Error) { }

    func errorManager(_ errorManager: LolayErrorManager, localizedStringForKey key: String) -> String? {
        return errorManager.errorManager(errorManager, localizedStringForKey: key)
    }

    func errorManager(_ errorManager: LolayErrorManager, titleForError error: Error) -> String {
        return errorManager.errorManager(errorManager, titleForError: error)
    }

    func errorManager(_ errorManager: LolayErrorManager, messageForError error: Error) -> String? {
        return errorManager.errorManager(errorManager, messageForError: error)
    }

    func errorManager(_ errorManager: LolayErrorManager, buttonTextForError error: Error) -> String {
        return errorManager.errorManager(errorManager, buttonTextForError: error)
    }
}

@Suite
@MainActor
struct LolayErrorManagerTests {
    func runTests(useTableName: Bool, delegate: LolayErrorDelegate?, error: Error, prefix: String, titlePrefix: String, buttonPrefix: String) {
        let tableName: String? = useTableName ? "LolayErredTests" : nil
        let manager = LolayErrorManager(bundle: Bundle.module, tableName: tableName)
        manager.delegate = delegate

        let title = manager.titleForError(error)
        let expectedTitle = titlePrefix + ":" + "LOCALIZED_TITLE"
        #expect(title == expectedTitle)

        let message = manager.messageForError(error)
        var expectedMessage = prefix + ":LOCALIZED_DESCRIPTION\n"
        expectedMessage += prefix + ":FAILURE_REASON\n"
        expectedMessage += prefix + ":RECOVERY_SUGGESTION"
        #expect(message == expectedMessage)

        let buttonText = manager.buttonTextForError(error)
        let expectedButtonText = buttonPrefix + ":" + "BUTTON_TEXT"
        #expect(buttonText == expectedButtonText)
    }

    @Test func localizedError() {
        runTests(useTableName: false, delegate: nil, error: TestLocalizedError(errorDescription: "CLS:LOCALIZED_DESCRIPTION", failureReason: "CLS:FAILURE_REASON", recoverySuggestion: "CLS:RECOVERY_SUGGESTION"), prefix: "CLS", titlePrefix: "LOCLE", buttonPrefix: "LOCLE")
    }

    @Test func nilTableNameNilDelegate() {
        runTests(useTableName: false, delegate: nil, error: EnumError.firstEnum, prefix: "LOCENM", titlePrefix: "LOCENM", buttonPrefix: "LOCENM")
    }

    @Test func tableNameNilDelegate() {
        runTests(useTableName: true, delegate: nil, error: EnumError.firstEnum, prefix: "ERRLOCENM", titlePrefix: "ERRLOCENM", buttonPrefix: "ERRLOCENM")
    }

    @Test func tableNameDelegate() {
        let delegate = PassthroughDelegate()
        runTests(useTableName: true, delegate: delegate, error: EnumError.firstEnum, prefix: "ERRLOCENM", titlePrefix: "ERRLOCENM", buttonPrefix: "ERRLOCENM")
    }

    @Test func defaults() {
        let manager = LolayErrorManager(bundle: Bundle.module, tableName: "invalid")
        #expect(manager.titleForError(EnumError.firstEnum) == "Whoops!")
        #expect(manager.buttonTextForError(EnumError.firstEnum) == "OK")
    }
}
