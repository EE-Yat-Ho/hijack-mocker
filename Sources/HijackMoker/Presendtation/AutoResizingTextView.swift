//
//  AutoResizingTextView.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/19/24.
//

import Foundation
import SwiftUI

struct AutoResizingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @Binding var inputHeight: CGFloat
    
    func makeUIView(context: UIViewRepresentableContext<AutoResizingTextView>) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 14)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }
    
    func makeCoordinator() -> AutoResizingTextView.Coordinator {
        Coordinator(text: self.$text, isFocused: self.$isFocused, inputHeight: $inputHeight)
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<AutoResizingTextView>) {
        uiView.text = self.text
        DispatchQueue.main.async {
            context.coordinator.updateSize(uiView)
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool
        @Binding var inputHeight: CGFloat
        
        let minHeight: CGFloat = 40
        let maxHeight: CGFloat = 200
        
        init(text: Binding<String>, isFocused: Binding<Bool>, inputHeight: Binding<CGFloat>) {
            self._text = text
            self._isFocused = isFocused
            self._inputHeight = inputHeight
        }
        
        func textViewDidChange(_ textView: UITextView) {
            updateSize(textView)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.text = textView.text ?? ""
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            self.isFocused = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            self.isFocused = false
        }
        
        func updateSize(_ textView: UITextView) {
            if textView.contentSize.height < minHeight {
                inputHeight = minHeight
            }
            else if textView.contentSize.height > maxHeight {
                inputHeight = maxHeight
            }
            else {
                inputHeight = textView.contentSize.height
            }
        }
    }
}
