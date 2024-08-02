//
//  HijackMokerList.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/1/24.
//

import Foundation
import SwiftUI

struct HijackMokerList: View {
    @ObservedObject
    var apis: MockAPIs
    @State private var needsUpdate = false
    
    private func sendAllButtonDidTap() {
        HijackMokerService.fireAll()
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    
                    appBar
                    
                    title
                
                    Spacer()
                
                    forEachAPICells
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .colorMultiply(.white.opacity(0.75))
    }
    
    private var appBar: some View {
        HStack {
            Spacer()
            Button { // Send All 버튼
                sendAllButtonDidTap()
            } label: {
                Text("Send All")
            }
            .padding()
        }
    }
    
    private var title: some View {
        Text("수정 가능한 API들")
            .foregroundColor(.black)
            .font(.title2)
            .bold()
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var forEachAPICells: some View {
        ForEach(apis.apis, id: \.id) { api in
            HijackMokerListCell(api: api)
                .background(Color.white)
                .cornerRadius(12)
                .padding([.horizontal])
        }
    }
    
}
