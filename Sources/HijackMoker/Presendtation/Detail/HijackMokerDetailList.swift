//
//  HijackMokerDetailList.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/1/24.
//

import Foundation
import SwiftUI

struct HijackMokerDetailList: View {
    
    @ObservedObject var api: MockAPI
    
    var body: some View {
        VStack {
            title
            subTitle
            
            releaseTypePicker
            
            switch api.type {
            case .request:
                requestList
                
            case .response:
                responseList
            }
        }
        .background(Color.white)
    }
    
    private var title: some View {
        Text("API 수정하기")
            .foregroundColor(.black)
            .font(.title2)
            .bold()
            .padding([.top, .horizontal])
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture { hideKeyboard() }
    }
    
    private var subTitle: some View {
        HStack {
            VStack(spacing: 3) {
                Text("\(api.method) \(api.pathAndQuery)")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                Text(api.schemeAndHost)
                    .foregroundColor(.black.opacity(0.5))
                    .font(.caption2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal)
    }
    
    private var releaseTypePicker: some View {
        Picker("Pick", selection: $api.type) {
            ForEach(MockAPI.ReleaseType.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color.white)
    }
    
    @ViewBuilder
    private var requestList: some View {
        if let items = api.requestRoot?.items, !items.isEmpty {
            List(items, children: \.items) { item in
                HijackMokerDetailListCell(item: item)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 0) // row의 최소 높이 44에서 0으로 설정.
            .background(Color.white)
        } else {
            Text("Request Header, Body, Query Params are Empty")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var responseList: some View {
        if let items = api.responseRoot?.items, !items.isEmpty {
            List(items, children: \.items) { item in
                HijackMokerDetailListCell(item: item)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 0) // row의 최소 높이 44에서 0으로 설정.
            .background(Color.white)
        } else {
            Text("Response Data is Empty")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
