//
//  MockAPI.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/5/24.
//

import Foundation
import Combine

/// API 하나를 표현하는 모델
public final class MockAPI: Hashable, Equatable, ObservableObject {
    
    enum DataType {
        case dict
        case array
        case string
        case int
        case double
        case bool
        case null
    }

    enum ReleaseType: String, CaseIterable {
        case request = "Request 수정 및 재통신" // 수정한 request로 다시 Network통신을 한 후, App으로 흘려 보냅니다
        case response = "Response 수정하여 사용" // 수정한 response를 App으로 흘려 보냅니다
    }
    
    deinit {
        print("🥷🏻🖐 MockAPI deinit")
    }
    
    init(request: URLRequest, data: Data?, response: URLResponse?, error: Error?, sendHandler: ((Data?, URLResponse?, Error?) -> ())?) {
        self.request = request
        self.data = data
        self.response = response
        self.error = error
        self.sendHandler = sendHandler
    }
    
    public static func == (lhs: MockAPI, rhs: MockAPI) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID = UUID()
    
    var request: URLRequest
    var data: Data?
    var response: URLResponse?
    var error: Error?
    var sendHandler: ((Data?, URLResponse?, Error?) -> ())?
    
    private var cancellables = Set<AnyCancellable>()
    
    public func processingInputs() {
        // set responseRoot
        if let data {
            self.responseRoot = try? KeyValueNode.decoding(data)
        }
        
        // set requestRoot
        var header: KeyValueNode?
        if let dict = request.allHTTPHeaderFields, !dict.isEmpty {
            header = try? KeyValueNode.decoding(key: "header", dict)
        }
        var body: KeyValueNode?
        if let data = getBodyData(request: request) {
            body = try? KeyValueNode.decoding(key: "body", data)
        }
        var query: KeyValueNode?
        if let dict = getQueryParams(request: request) {
            query = try? KeyValueNode.decoding(key: "query", dict)
        }
        self.requestRoot = KeyValueNode.assemble([header, body, query].compactMap { $0 })
    }
    
    var statusCode: Int? {
        (response as? HTTPURLResponse)?.statusCode
    }
    var url: URL? {
        request.url
    }
    var schemeAndHost: String {
        (url?.scheme ?? "") + "://" + (url?.host ?? "")
    }
    var pathAndQuery: String {
        let path = url?.path ?? ""
        let query = url?.query ?? ""
        var pathAndQuery = path
        if !query.isEmpty { pathAndQuery.append("?\(query)") }
        return pathAndQuery
    }
    var method: String {
        request.httpMethod ?? ""
    }
    
    // MARK: - 수정되는 데이터들
    @Published
    var type: ReleaseType = .response
    @Published
    var responseRoot: KeyValueNode? {
        didSet {
            responseRoot?.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        }
    }
    @Published
    var requestRoot: KeyValueNode? {
        didSet {
            requestRoot?.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        }
    }
    
    func fire() throws {
        print("🥷🏻 fire type: \(type.rawValue)")
        switch type {
        case .request:
            var newRequest = request
            
            // 편집된 데이터로 request 헤더 만들기
            if let headerItem = requestRoot?.items?.first(where: { $0.name == "header"}),
               let headerAny = try KeyValueNode.modelToDict(data: headerItem)["header"] {
                let headerDict = try anyToStringStringDict(any: headerAny)
                newRequest.allHTTPHeaderFields = headerDict
            }
            // 편집된 데이터로 request 바디 만들기
            if let bodyItem = requestRoot?.items?.first(where: { $0.name == "body"}) {
                newRequest.httpBody = try KeyValueNode.encoding(key: "body", bodyItem)
            }
            // 편집된 데이터로 request 쿼리파라미터 만들기
            if let queryItem = requestRoot?.items?.first(where: { $0.name == "query"}) {
                if let urlString = newRequest.url?.absoluteString,
                   var urlComponents = URLComponents(string: urlString),
                   let queryAny = try KeyValueNode.modelToDict(data: queryItem)["query"] {
                    let queryDict = try anyToStringStringDict(any: queryAny)
                    urlComponents.queryItems = queryDict.map { URLQueryItem(name: $0.key, value: $0.value) }
                    newRequest.url = urlComponents.url
                }
            }
            
            print("🥷🏻🚀 newRequest: \(newRequest)")
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = HijackMokerService.timeout
            let session = URLSession(configuration: config)
            
            session.dataTask(with: newRequest) { [weak self] data, response, error in
                print("🥷🏻🔥 request: \(newRequest), statusCode: \((response as? HTTPURLResponse)?.statusCode.description ?? "nil"), error: \(error?.localizedDescription ?? "nil")")
                self?.sendHandler?(data, response, error)
            }.resume()
            
        case .response:
            if let responseRoot, let response {
                let data = (try? KeyValueNode.encoding(responseRoot)) ?? Data()
                sendHandler?(data, response, nil)
            } else {
                sendHandler?(nil, nil, error)
            }
        }
    }
    
}
