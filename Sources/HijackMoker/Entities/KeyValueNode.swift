//
//  KeyValueNode.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/4/24.
//

import Foundation

/// API 상세에서, 키-값 하나를 담당하는 모델
final class KeyValueNode: Identifiable, Equatable, ObservableObject {
    static func == (lhs: KeyValueNode, rhs: KeyValueNode) -> Bool {
        lhs.id == rhs.id
    }
    
    private static let intChar = String(cString: NSNumber(value: Int()).objCType)
    private static let boolChat = String(cString: NSNumber(value: Bool()).objCType)
    private static let doubleChat = String(cString: NSNumber(value: Double()).objCType)
    
    init(name: String, items: [KeyValueNode]? = nil, value: Any? = nil, type: MockAPI.DataType) {
        self.name = name
        self.items = items
        self.value = value
        self.type = type
        self.originalCount = items?.count ?? 0
        self.originalFirstItem = items?.first
        items?.forEach { $0.setSuperItem(superItem: self) }
        if let value {
            self.text = "\(value)"
            if type == .bool { self.bool = "\(value)" == "1" }
        }
    }
    
    let id = UUID()
    let name: String // 좌측에 보여줄 타이틀
    private let icon: String = "" // 사용하지 않는 값
    
    var type: MockAPI.DataType // 값의 타입 (dict, array, string, int, double, bool, null)
    
    weak var superItem: KeyValueNode?
    var items: [KeyValueNode]? // 이게 있다면, 자식을 펼치는 셀 (dict, array)
    var value: Any? // 이게 있다면, 값을 편집하는 셀 (string, int, double, bool, null)
    var isAddedItem: Bool = false
    private let originalCount: Int
    let originalFirstItem: KeyValueNode?
    
    @Published
    var text: String = "" { // TextView에 바인딩할 텍스트 (string, int, double, null)
        didSet {
            calculateIsEdited()
        }
    }
    @Published
    var bool: Bool = false { // Toggle에 바인딩할 불리언값 (bool)
        didSet {
            calculateIsEdited()
        }
    }
    @Published
    var isEdited: Bool = false
    
    func calculateIsEdited() {
        var me = false
        if type == .bool, let v = value as? Bool {
            me = v != bool
        }
        else if let v = value as? String {
            me = v != text
        }
        else if let v = value as? Int {
            me = v != Int(text)
        }
        else if type == .array {
            me = items?.count != originalCount
        }
        
        let child = items?.contains(where: { $0.isEdited || $0.isAddedItem }) ?? false

        isEdited = me || child
        superItem?.calculateIsEdited()
    }
    
    func addable() -> Bool {
        if type != .array { return false }
        if originalFirstItem != nil { return true }
        return false
    }
    
    func setSuperItem(superItem: KeyValueNode?) {
        self.superItem = superItem
    }
    
    // 최상위 key를 넣어서 decoding (Data -> Node)
    static func decoding(key: String = "root", _ data: Data) throws -> KeyValueNode {
        let dict = (try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
        return try dictToModel(key: key, value: dict)
    }
    // 최상위 key를 넣어서 decoding (NSDictionary -> Node)
    static func decoding(key: String = "root", _ dict: [String: Any]) throws -> KeyValueNode {
        return try dictToModel(key: key, value: dict)
    }
    // 최상위 key를 뺀채로 encoding (Node -> Data)
    static func encoding(key: String = "root", _ model: KeyValueNode) throws -> Data {
        let dict = try modelToDict(data: model)
        return try encoding(key: key, dict)
    }
    // 최상위 key를 뺀채로 encoding (Node -> NSDictionary)
    static func encoding(key: String = "root", _ dict: [String: Any]) throws -> Data {
        return try JSONSerialization.data(withJSONObject: dict[key]!)
    }
    
    static func assemble(_ models: [KeyValueNode]) -> KeyValueNode {
        KeyValueNode(name: "root", items: models, type: .dict)
    }
    
    static func copy(_ node: KeyValueNode) -> KeyValueNode {
        let new = KeyValueNode(
            name: "\(node.name)",
            items: node.items?.map { KeyValueNode.copy($0) },
            value: node.type == .int ? Int.random(in: 1000000...1999999) : node.value,
            type: node.type
        )
        new.superItem = node.superItem
        new.isAddedItem = true
        new.calculateIsEdited()
        return new
    }
    
    private static func dictToModel(key: String, value: Any) throws -> KeyValueNode {
        let name = key
        if let child = value as? [String: Any] {
            let items = try child.map {
                try dictToModel(key: $0.key, value: $0.value)
            }
            return KeyValueNode(name: name, items: items, type: .dict)
        }
        else if let child = value as? Array<Any> {
            let items = try child.enumerated().map {
                try dictToModel(key: "\(key)[\($0.offset)]", value: $0.element)
            }
            return KeyValueNode(name: name, items: items, type: .array)
        }
        else if let v = value as? String {
            return KeyValueNode(name: name, value: v, type: .string)
        }
        else if let v = value as? NSNumber {
            let type = try checkClassType(v) // int, bool, double
            return KeyValueNode(name: name, value: v, type: type)
        }
        else if let v = value as? NSNull {
            return KeyValueNode(name: name, value: v, type: .null)
        }
        else {
            throw NSError(domain: "이게 진짜 일리 없어", code: -1)
        }
    }
    
    private static func checkClassType(_ object: NSNumber) throws -> MockAPI.DataType {
        let char = String(cString: object.objCType)
        switch char {
        case intChar:
            return .int
        case boolChat:
            return .bool
        case doubleChat:
            return .double
        default:
            throw NSError(domain: "예상치 못한 Type이 들어옴 \(char)", code: -1)
        }
    }
    
    static func modelToDict(data: KeyValueNode) throws -> [String: Any] {
        switch data.type {
        case .dict:
            var value: [String: Any] = [:]
            try data.items?.forEach {
                let dict = try modelToDict(data: $0)
                dict.keys.forEach {
                    value[$0] = dict[$0]
                }
            }
            return [data.name: value]
        case .array:
            let value = try data.items?
                .flatMap { try modelToDict(data: $0) }
                .map { $0.value } ?? []
            return [data.name: value]
        case .string:
            let value = data.text
            return [data.name: value]
        case .int:
            if let value = Int(data.text) {
                return [data.name: value]
            }
        case .double:
            if let value = Double(data.text) {
                return [data.name: value]
            }
        case .bool:
            let value = data.bool
            return [data.name: value]
        case .null:
            if let value = data.value as? NSNull {
                return [data.name: value]
            }
        }
        throw NSError(domain: "이게 진짜 일리 없어", code: -1)
    }
}
