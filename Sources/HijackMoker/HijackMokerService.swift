//
//  HijackMokerService.swift
//  LKNetwork
//
//  Created by 영호 박 on 6/24/24.
//

import SwiftUI

public final class HijackMokerService {
    
    @ObservedObject
    private static var viewModel = MockAPIs(apis: [])
    
    private(set) static var isRunning = true
    private(set) static var timeout = 10.0
    
    public static func start() {
        isRunning = true
    }
    public static func stop() {
        isRunning = false
    }
    public static func setTimeout(second: CGFloat) {
        timeout = second
    }
    
    static func fireAll() {
        DispatchQueue.main.async {
            let apis = viewModel.apis
            viewModel.apis.removeAll()
            apis.forEach {
                do {
                    try $0.fire()
                } catch {
                    print("🥷🏻👻", error)
                }
            }
            dismiss()
        }
    }
    
    static func append(_ request: URLRequest, _ data: Data?, _ response: URLResponse?, _ error: Error?, sendHandler: @escaping ((Data?, URLResponse?, Error?) -> ())) {
        let api = MockAPI(request: request, data: data, response: response, error: error, sendHandler: sendHandler)
        api.processingInputs()
        
        DispatchQueue.main.async {
            viewModel.apis.append(api)
            show()
        }
    }
    
    private static func show() {
        print("🥷🏻 show apis.count: \(HijackMokerService.viewModel.apis.count)")
        let topVC = UIApplication.shared.windows.first?.rootViewController
        
        let vc = UIHostingController(rootView: HijackMokerList(apis: viewModel))
        vc.view.backgroundColor = .clear
        vc.isModalInPresentation = true
        vc.modalPresentationStyle = .overFullScreen
        topVC?.present(vc, animated: true)
    }
    
    private static func dismiss() {
        print("🥷🏻 dismiss")
        let topVC = UIApplication.shared.windows.first?.rootViewController
        topVC?.dismiss(animated: true)
    }
    
}

