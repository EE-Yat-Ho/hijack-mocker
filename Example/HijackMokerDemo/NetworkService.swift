//
//  NetworkService.swift
//  HijackMokerDemo
//
//  Created by 영호 박 on 8/2/24.
//

import Foundation
import HijackMoker

final class NetworkService {
    
    func get(offset: Int, limit: Int) async throws -> PoketMons {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)")!
        let (data, _) = try await createSession(timeout: 10).data(from: url)
        
        return try JSONDecoder().decode(PoketMons.self, from: data)
    }
    
    private func createSession(timeout: CGFloat = 10) -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        if StaticMethods.useHijackMoker() {
            HijackMokerService.setTimeout(second: timeout)
            configuration.timeoutIntervalForRequest = .infinity
            configuration.protocolClasses = [HijackMokerURLProtocol.self]
        } else {
            configuration.timeoutIntervalForRequest = timeout
        }
        return URLSession(configuration: configuration)
    }
    
}
