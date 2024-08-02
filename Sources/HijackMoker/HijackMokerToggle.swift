//
//  File.swift
//  
//
//  Created by 영호 박 on 8/1/24.
//

import SwiftUI

public struct HijackMokerToggle: View {
    
    let gray = Color(white: 0.9)
    let blue = Color(red: 0, green: 123.0/255.0, blue: 247.0/255.0).opacity(0.5)
    
    public init() {
        self.isOn = isOn
    }
    
    @State
    var isOn = HijackMoekrIsOn
    
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Toggle("", isOn: $isOn)
                    .toggleStyle(HijackMokerToggleStyle(onColor: blue, offColor: gray, thumbColor: blue))
                    .onChange(of: isOn) { value in
                        HijackMoekrIsOn = value
                    }
                Spacer()
            }
            Spacer()
        }
    }
    
}

struct HijackMokerToggleStyle: ToggleStyle {

    var onColor: Color
    var offColor: Color
    var thumbColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(thumbColor)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .onTapGesture {
                    withAnimation(.smooth(duration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
