import Foundation
import XCTest
import XMLCoder

class CharacterDataDecodingTestCase: DecodingTestCase {
    override func setUp() {
        super.setUp()
        decoder.characterDataToken = "#text"
    }

    func testItDecodesValuesCodedAsElements() {
        // given
        struct Element: Decodable, Equatable {
            let key: String?
        }
        let xml = """
        <element><key>My value</key></element>
        """

        do {
            // when
            let el: Element = try decode(xml)

            // then
            XCTAssertEqual(el, Element(key: "My value"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItDecodesValuesCodedAsAttributes() {
        // given
        struct Element: Decodable, Equatable {
            let key: String?
        }
        let xml = """
        <element key="My value"></element>
        """

        do {
            // when
            let el: Element = try decode(xml)

            // then
            XCTAssertEqual(el, Element(key: "My value"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItDecodesCharData() {
        // given
        struct Attribute: Decodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case name
                case value = "#text"
            }

            let name: String
            let value: String
        }
        let xml = """
        <attribute name="Xpos">0</attribute>
        """

        do {
            // when
            let attr: Attribute = try decode(xml)

            // then
            XCTAssertEqual(attr, Attribute(name: "Xpos", value: "0"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItDecodesCharDataWhenNested() {
        // given
        struct Item: Decodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case id = "ID"
                case creator = "Creator"
                case children = "attribute"
            }

            let id: String
            let creator: String
            let children: [Attribute]?
        }

        struct Attribute: Decodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case name
                case value = "#text"
            }

            let name: String
            let value: String?
        }

        let xml = """
        <item ID="1542637462" Creator="Francisco Moya">
        <attribute name="Xpos">0</attribute>
        </item>
        """

        // when
        do {
            let result: Item = try decode(xml)

            // then
            let expected = Item(id: "1542637462", creator: "Francisco Moya", children: [
                Attribute(name: "Xpos", value: "0"),
            ])
            XCTAssertEqual(result, expected)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
