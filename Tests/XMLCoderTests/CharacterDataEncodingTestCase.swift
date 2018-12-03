import Foundation
import XCTest
import XMLCoder

class CharacterDataEncodingTestCase: EncodingTestCase {
    override func setUp() {
        super.setUp()
        encoder.characterDataToken = "#text"
        if #available(OSX 10.13, *) {
            encoder.outputFormatting = .sortedKeys
        }
    }

    func testItEncodesElementValues() {
        // given
        struct Element: Encodable {
            let key: String?
        }
        let el = Element(key: "My value")

        do {
            // when
            let xml = try encode(el, withRootKey: "element")

            // then
            let expected = """
            <element><key>My value</key></element>
            """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItEncodesAttributeValues() {
        // given
        struct Element: Encodable {
            let key: String?
        }
        let el = Element(key: "My value")
        encoder.nodeEncodingStrategy = .custom { _, _ in
            return { _ in .attribute }
        }

        do {
            // when
            let xml = try encode(el, withRootKey: "element")

            // then
            let expected = """
            <element key="My value" />
            """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItEncodesCharDataWhenTheStrategyIsAttribute() {
        // given
        struct Attribute: Encodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case name
                case value = "#text"
            }

            let name: String
            let value: String
        }
        let el = Attribute(name: "Xpos", value: "0")

        encoder.nodeEncodingStrategy = .custom { _, _ in
            return { _ in .attribute }
        }

        do {
            // when
            let xml = try encode(el, withRootKey: "attribute")

            // then
            let expected = """
            <attribute name="Xpos">0</attribute>
            """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItEncodesCharDataWhenTheStrategyIsElement() {
        // given
        struct Attribute: Encodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case name
                case value = "#text"
            }

            let name: String
            let value: String
        }
        let el = Attribute(name: "Xpos", value: "0")

        encoder.nodeEncodingStrategy = .custom { _, _ in
            return { _ in .element }
        }

        do {
            // when
            let xml = try encode(el, withRootKey: "attribute")

            // then
            let expected = """
            <attribute>0<name>Xpos</name></attribute>
            """
            XCTAssertEqual(xml, expected)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItEncodesCharDataWhenNested() {
        // given
        struct Item: Encodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case id = "ID"
                case creator = "Creator"
                case children = "attribute"
            }

            let id: String
            let creator: String
            let children: [Attribute]?
        }

        struct Attribute: Encodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case name
                case value = "#text"
            }

            let name: String
            let value: String?
        }

        let item = Item(id: "1542637462", creator: "Francisco Moya", children: [
            Attribute(name: "Xpos", value: "0"),
        ])

        encoder.nodeEncodingStrategy = .custom { type, _ in
            if type == Item.self {
                return { key in
                    switch key as! Item.CodingKeys {
                    case .children:
                        return .element
                    case .creator, .id:
                        return .attribute
                    }
                }
            }
            return { _ in .attribute }
        }

        // when
        do {
            let result = try encode(item, withRootKey: "item")

            // then
            let expected = """
            <item Creator="Francisco Moya" ID="1542637462"><attribute name="Xpos">0</attribute></item>
            """
            XCTAssertEqual(result, expected)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

	func testItEncodesCharDataWhenNestedAndPrettyPrinted() {
		if #available(OSX 10.13, *) {
			encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
		}

		struct Item: Encodable, Equatable {
			enum CodingKeys: String, CodingKey {
				case id = "ID"
				case creator = "Creator"
				case children = "attribute"
			}

			let id: String
			let creator: String
			let children: [Attribute]?
		}

		struct Attribute: Encodable, Equatable {
			enum CodingKeys: String, CodingKey {
				case name
				case value = "#text"
			}

			let name: String
			let value: String?
		}

		let item = Item(id: "1542637462", creator: "Francisco Moya", children: [
			Attribute(name: "Xpos", value: "0"),
			])

		encoder.nodeEncodingStrategy = .custom { type, _ in
			if type == Item.self {
				return { key in
					switch key as! Item.CodingKeys {
					case .children:
						return .element
					case .creator, .id:
						return .attribute
					}
				}
			}
			return { _ in .attribute }
		}

		// when
		do {
			let result = try encode(item, withRootKey: "item")

			// then
			let expected = """
            <item Creator="Francisco Moya" ID="1542637462">
                <attribute name="Xpos">0</attribute>
            </item>
            """
			XCTAssertEqual(result, expected)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
