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

public protocol LolayUnderlyingableError: Error {
    var underlyingError: Error { get }
}

public extension LolayUnderlyingableError where Self: LolayUnderlyingableError {
    public func recursiveUnderlyingError() -> Error? {
        var error: Error? = self
        var lastError: Error? = nil
        
        repeat {
            lastError = error! // Guaranteed as how the repeat-while clause works
            if let underlyingableError = error as? LolayUnderlyingableError {
                error = underlyingableError.underlyingError
            } else {
                error = nil
            }
        } while (error != nil)
        
        return lastError
    }
    
    public func recursiveUnderlyingErrorOrSelf() -> Error {
        let error = self.recursiveUnderlyingError()
        return error != nil ? error! : self
    }
}
