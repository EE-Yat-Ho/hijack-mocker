//
//  HijackMokerListCell.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/19/24.
//

import SwiftUI

struct HijackMokerListCell: View {
    
    @ObservedObject var api: MockAPI
    
    var body: some View {
        var statusCodeText = "❌🌏"
        if let statusCode = api.statusCode {
            statusCodeText = "\(statusCode)"
        }
        
        let guideText: String
        let guideColor: Color
        let requestIsEdited = api.requestRoot?.isEdited ?? false
        let responseIsEdited = api.responseRoot?.isEdited ?? false
        if api.type == .request, requestIsEdited {
            guideText = "수정된 요청으로 통신 후, 응답을 앱에 보냅니다."
            guideColor = .orange
        }
        else if api.type == .request {
            guideText = "똑같은 요청으로 통신 후, 응답을 앱에 보냅니다."
            guideColor = .green
        }
        else if api.type == .response, responseIsEdited {
            guideText = "수정된 응답을 앱에 보냅니다."
            guideColor = .orange
        }
        else {
            guideText = "응답을 그대로 앱에 보냅니다."
            guideColor = .green
        }
        
        return NavigationLink(destination: HijackMokerDetailList(api: api)) {
            HStack {
                Text(statusCodeText)
                    .foregroundColor(api.statusCode == 200 ? .green : .red)
                    .fontWeight(.bold)
                    .padding()
                
                VStack(spacing: 3) {
                    Text("\(api.method) \(api.pathAndQuery)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 8)
                    
                    Text(api.schemeAndHost)
                        .foregroundColor(.black.opacity(0.5))
                        .font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 8)
                    
                    Text(guideText)
                        .foregroundColor(guideColor)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 8)
                }
                
                Image(systemName: "chevron.right")
                    .padding()
            }
        }
    }
}
