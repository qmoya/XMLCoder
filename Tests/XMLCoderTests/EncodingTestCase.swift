import Foundation
import XCTest
import XMLCoder

class EncodingTestCase: XCTestCase {
    var encoder: XMLEncoder!

    func encode<T>(_ value: T, withRootKey key: String) throws -> String where T: Encodable {
        let data = try encoder.encode(value, withRootKey: key)
        let result = String(data: data, encoding: .utf8)!
        return result
    }

    override func setUp() {
        super.setUp()
        encoder = XMLEncoder()
    }

    override func tearDown() {
        encoder = nil
        super.tearDown()
    }
}
