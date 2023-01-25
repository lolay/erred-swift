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

import XCTest
@testable import LolayErred

class LolayErredTests: XCTestCase {
    struct UnderlyingableError: LolayUnderlyingableError, Equatable {
        let underlyingError: Error?
        
        init(underlyingError: Error?) {
            self.underlyingError = underlyingError
        }
        
        static func == (lhs: UnderlyingableError, rhs: UnderlyingableError) -> Bool {
            if (lhs.underlyingError == nil && rhs.underlyingError == nil) {
                return true
            } else if (lhs.underlyingError == nil || rhs.underlyingError == nil) {
                return false
            }
            
            let lhse = lhs.underlyingError!
            let rhse = rhs.underlyingError!
            
            return lhse.localizedDescription == rhse.localizedDescription
        }
    }
    
    enum NormalError: Error, Equatable {
        case root
    }
    
    func testNested() {
        let rootError = NormalError.root
        let intermediateError = UnderlyingableError(underlyingError: rootError)
        let topError = UnderlyingableError(underlyingError: intermediateError)
        
        let underlyingError = topError.recursiveUnderlyingError()
        XCTAssertNotNil(underlyingError)
        XCTAssertEqual(rootError, underlyingError as! NormalError)
        
        let underlyingErrorOrSelf = topError.recursiveUnderlyingError()
        XCTAssertNotNil(underlyingErrorOrSelf)
        XCTAssertEqual(rootError, underlyingErrorOrSelf as! NormalError)
        
        let noUnderlyingError = UnderlyingableError(underlyingError: nil)
        XCTAssertNil(noUnderlyingError.underlyingError)
        XCTAssertEqual(noUnderlyingError, noUnderlyingError.recursiveUnderlyingErrorOrSelf() as! UnderlyingableError)
    }
}
