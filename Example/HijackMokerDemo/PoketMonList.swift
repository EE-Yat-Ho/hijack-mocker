//
//  PoketMonList.swift
//  HijackMokerDemo
//
//  Created by 영호 박 on 8/1/24.
//

import SwiftUI
import HijackMoker

struct PoketMonList: View {
    
    @ObservedObject
    var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Button(action: {
                Task { await viewModel.fetch() }
            }, label: {
                Text("Get PoketMons")
            })
            .padding()
            
            HStack {
                Text("offset")
                    .padding([.horizontal, .top])
                    .frame(width: 90)
                TextField("", text: $viewModel.offset)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding([.trailing, .top])
            }
            HStack {
                Text("limit")
                    .padding([.horizontal])
                    .frame(width: 90)
                TextField("", text: $viewModel.limit)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding([.trailing])
            }
            List {
                ForEach(viewModel.poketMons.results, id: \.name) { poketMon in
                    HStack {
                        if let url = URL(string: poketMon.imageUrl) {
                            AsyncImage(url: url) { result in
                                result.image?
                                    .resizable()
                                    .scaledToFill()
                            }
                            .frame(width: 70, height: 70)
                        }
                        
                        Text(poketMon.name)
                            .padding()
                    }
                }
            }
        }
        .task {
            await viewModel.fetch()
        }
    }
}
