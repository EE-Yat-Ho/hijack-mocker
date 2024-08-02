//
//  Utils.swift
//  HiJackMoker
//
//  Created by 영호 박 on 7/29/24.
//

import Foundation

var HijackMoekrIsOn: Bool {
    get {
        UserDefaults.standard.bool(forKey: "HijackMokerSwitch")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "HijackMokerSwitch")
    }
}

func getQueryParams(request: URLRequest) -> [String: String]? {
    guard let url = request.url,
          let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = urlComponents.queryItems else {
        return nil
    }
    
    var result: [String: String] = [:]
    queryItems.forEach {
        result[$0.name] = $0.value
    }
    return result
}

func anyToStringStringDict(any: Any) throws -> [String: String] {
    if let dict = any as? [String: String] {
        return dict
    }
    else if let dict = any as? [String: Int] {
        return dict.mapValues { "\($0)" }
    }
    else {
        throw NSError(domain: "Any를 Dictionary로 변환하는데 실패", code: -1)
    }
}


func getBodyData(request: URLRequest) -> Data? {
    
    /// This data is sent as the message body of the request, as
    /// in done in an HTTP POST request.
    if let getBody = request.httpBody {
        return getBody
    }

    /// The stream is returned for examination only; it is
    /// not safe for the caller to manipulate the stream in any way.  Also
    /// note that the HTTPBodyStream and HTTPBody are mutually exclusive - only
    /// one can be set on a given request.  Also note that the body stream is
    /// preserved across copies, but is LOST when the request is coded via the
    /// NSCoding protocol
    if let bodyStream = request.httpBodyStream {
        
        bodyStream.open()
        
        // Will read 16 chars per iteration. Can use bigger buffer if needed
        let bufferSize: Int = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        var data = Data()
        
        while bodyStream.hasBytesAvailable {
            let readDat = bodyStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readDat)
        }
        
        buffer.deallocate()
        bodyStream.close()
        
        return data
    }
    
    return nil
}
