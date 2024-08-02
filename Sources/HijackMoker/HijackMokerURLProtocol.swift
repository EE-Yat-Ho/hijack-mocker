//
//  HijackMokerURLProtocol.swift
//  HiJackMoker
//
//  Created by 영호 박 on 7/29/24.
//

import Foundation

public class HijackMokerURLProtocol: URLProtocol {
    
    // 처리할 요청인지 확인
    public override class func canInit(with request: URLRequest) -> Bool {
        // 모든 요청을 처리하도록 설정
        return true
    }
    
    // Request 수정
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // 요청 시작
    public override func startLoading() {
        print("🥷🏻 HijackMokerURLProtocol startLoading request: \(request)")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = HijackMokerService.timeout
        
        if HijackMoekrIsOn {
            URLSession(configuration: config).dataTask(with: request) { data, response, error in
                HijackMokerService.append(self.request, data, response, error) { data, response, error in
                    if let data {
                        self.client?.urlProtocol(self, didLoad: data)
                    }
                    if let response {
                        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    }
                    if let error {
                        self.client?.urlProtocol(self, didFailWithError: error)
                    }
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            }.resume()
        } else {
            URLSession(configuration: config).dataTask(with: request) { data, response, error in
                if let data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                if let response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let error {
                    self.client?.urlProtocol(self, didFailWithError: error)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }.resume()
        }
    }
    
    // 요청 중지
    public override func stopLoading() {}
}
