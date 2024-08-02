//
//  MockAPIs.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/19/24.
//

import Foundation

/// API 리스트를 표현하는 모델
final class MockAPIs: ObservableObject {
    deinit {
        print("🥷🏻🖐 MockAPIs deinit")
    }
    @Published var apis: [MockAPI]
    
    init(apis: [MockAPI]) {
        self.apis = apis
    }
}
