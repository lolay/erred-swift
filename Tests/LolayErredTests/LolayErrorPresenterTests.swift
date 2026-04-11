//  Copyright © 2026 Lolay, Inc.
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

@MainActor
final class RecordingPresenter: LolayErrorPresenter {
    struct PresentedError {
        let title: String
        let message: String?
        let buttonText: String
    }

    var presented: [PresentedError] = []
    var autoCallDismiss = true

    func present(title: String, message: String?, buttonText: String, onDismiss: (() -> Void)?) {
        presented.append(PresentedError(title: title, message: message, buttonText: buttonText))
        if autoCallDismiss {
            onDismiss?()
        }
    }
}

// Reuse EnumError from LolayErrorManagerTests — keys exist in Localizable.strings

@Suite
@MainActor
struct LolayErrorPresenterTests {
    @Test func presenterReceivesResolvedStrings() {
        let presenter = RecordingPresenter()
        let manager = LolayErrorManager(bundle: Bundle.module)
        manager.presenter = presenter

        manager.presentError(EnumError.firstEnum)

        #expect(presenter.presented.count == 1)
        let record = presenter.presented[0]
        #expect(record.title == "LOCENM:LOCALIZED_TITLE")
        #expect(record.buttonText == "LOCENM:BUTTON_TEXT")
        #expect(record.message != nil)
    }

    @Test func presenterNotCalledWhenDelegateSuppresses() {
        let presenter = RecordingPresenter()
        let delegate = SuppressingDelegate()
        let manager = LolayErrorManager(bundle: Bundle.module)
        manager.presenter = presenter
        manager.delegate = delegate

        manager.presentError(EnumError.firstEnum)

        #expect(presenter.presented.isEmpty)
        _ = delegate
    }

    @Test func showingErrorPreventsDoublePresentation() {
        let presenter = RecordingPresenter()
        presenter.autoCallDismiss = false
        let manager = LolayErrorManager(bundle: Bundle.module)
        manager.presenter = presenter

        manager.presentError(EnumError.firstEnum)
        manager.presentError(EnumError.firstEnum)

        #expect(presenter.presented.count == 1)
    }

    @Test func dismissResetsShowingError() {
        let presenter = RecordingPresenter()
        presenter.autoCallDismiss = true
        let manager = LolayErrorManager(bundle: Bundle.module)
        manager.presenter = presenter

        manager.presentError(EnumError.firstEnum)
        manager.presentError(EnumError.firstEnum)

        #expect(presenter.presented.count == 2)
    }

    @Test func onCancelCalledOnDismiss() {
        let presenter = RecordingPresenter()
        presenter.autoCallDismiss = true
        let manager = LolayErrorManager(bundle: Bundle.module)
        manager.presenter = presenter

        var cancelCalled = false
        manager.presentError(EnumError.firstEnum) { _, _ in
            cancelCalled = true
        }

        #expect(cancelCalled)
    }

    @Test func presentErrorsCallsPresenterForEach() {
        let presenter = RecordingPresenter()
        presenter.autoCallDismiss = true
        let manager = LolayErrorManager(bundle: Bundle.module)
        manager.presenter = presenter

        manager.presentErrors([EnumError.firstEnum, EnumError.firstEnum])

        #expect(presenter.presented.count == 2)
    }

    @Test func noPresenterDoesNotCrash() {
        let manager = LolayErrorManager(bundle: Bundle.module)
        manager.presentError(EnumError.firstEnum)
    }

    @Test func defaultsWithNoBundle() {
        let presenter = RecordingPresenter()
        let manager = LolayErrorManager()
        manager.presenter = presenter

        manager.presentError(EnumError.firstEnum)

        #expect(presenter.presented.count == 1)
        #expect(presenter.presented[0].title == "Whoops!")
        #expect(presenter.presented[0].buttonText == "OK")
    }
}

@MainActor
final class SuppressingDelegate: LolayErrorDelegate {
    func errorManager(_ errorManager: LolayErrorManager, shouldPresentError error: Error) -> Bool {
        return false
    }
    func errorManager(_ errorManager: LolayErrorManager, errorPresented error: Error) {}
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
