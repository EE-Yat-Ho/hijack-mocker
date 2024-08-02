//
//  HijackMokerDetailListCell.swift
//  LKNetwork
//
//  Created by 영호 박 on 7/19/24.
//

import Foundation
import SwiftUI

struct HijackMokerDetailListCell: View {
    
    init(item: KeyValueNode) {
        self.item = item
        
        switch item.type {
        case .string:
            keyboardType = .default
        case .int:
            keyboardType = .numberPad
        case .double:
            keyboardType = .decimalPad
        case .bool:
            keyboardType = nil
        case .null:
            keyboardType = .default
            disable = true
        default:
            keyboardType = nil
        }
    }
    
    @State private var open: Bool = false
    @State private var inputHeight: CGFloat = 40
    @ObservedObject private var item: KeyValueNode
    
    private let keyboardType: UIKeyboardType?
    private var disable: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                name
                
                if item.type == .bool {
                    toggle
                }
                else if item.type == .array {
                    Spacer()
                    
                    countText
                    
                    addButton
                }
                
                if keyboardType != nil {
                    textEditor
                }
                
                if item.superItem?.type == .array {
                    Spacer()
                    
                    minusButton
                }
            }
        }
    }
    
    private var name: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                if item.isAddedItem {
                    Text("추가됨")
                        .foregroundColor(.blue)
                        .font(.caption)
                        .bold()
                        .onTapGesture {
                            hideKeyboard()
                        }
                }
                if item.isEdited {
                    Text("수정됨")
                        .foregroundColor(.orange)
                        .font(.caption)
                        .bold()
                        .onTapGesture {
                            hideKeyboard()
                        }
                }
                if item.type == .array, !item.addable() {
                    Text("처음에 비어있던 Array는 값 추가가 불가능합니다.")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .bold()
                        .onTapGesture {
                            hideKeyboard()
                        }
                }
            }
            
            Text(item.name)
                .foregroundColor(.black)
                .font(.subheadline)
                .frame(width: UIScreen.main.bounds.size.width * 2 / 7, alignment: .leading) // 임의로 예쁜 비율을 찾음
                .multilineTextAlignment(.leading)
                .onTapGesture {
                    hideKeyboard()
                }
        }
    }
    
    private var toggle: some View {
        Toggle(isOn: $item.bool) {}
    }
    
    private var countText: some View {
        Text("\(item.items?.count ?? 0)")
            .foregroundColor(.gray)
            .font(.caption)
    }
    
    private var addButton: some View {
        Button(action: {
            guard let firstChild = item.originalFirstItem else {
                return
            }
            let new = KeyValueNode.copy(firstChild)
            item.items?.insert(new, at: 0)
            item.calculateIsEdited()
        }) {
            Text("+")
                .frame(width: 30, height: 30)
                .background(item.addable() ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!item.addable())
        }
        .buttonStyle(.plain)
    }
    
    private var minusButton: some View {
        Button(action: {
            print("- 버튼 클릭됨")
            item.superItem?.items?.removeAll(where: { $0.id == item.id })
            item.calculateIsEdited()
        }) {
            Text("-")
                .frame(width: 30, height: 30)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var textEditor: some View {
        AutoResizingTextView(text: $item.text, isFocused: .constant(false), inputHeight: $inputHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: inputHeight)
            .font(.subheadline)
            .keyboardType(keyboardType!)
            .background(disable ? Color.gray : Color.white)
            .disabled(disable)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
    
    /// 키보드 숨기기
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
