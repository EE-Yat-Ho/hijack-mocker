//
//  ViewModel.swift
//  HijackMokerDemo
//
//  Created by 영호 박 on 8/2/24.
//

import Foundation

final class ViewModel: ObservableObject {
    
    @Published
    var poketMons = PoketMons(results: []) {
        didSet {
            print("setted poketMons: \(poketMons)")
        }
    }
    
    @Published
    var offset: String = "0"
    @Published
    var limit: String = "10"
    
    private var service = NetworkService()
    
    func fetch() async {
        do {
            let offset = Int(offset) ?? 0
            let limit = Int(limit) ?? 0
            let poketMons = try await service.get(offset: offset, limit: limit)
            DispatchQueue.main.async {
                self.poketMons = poketMons
            }
        } catch {
            print(error)
        }
    }
    
}
