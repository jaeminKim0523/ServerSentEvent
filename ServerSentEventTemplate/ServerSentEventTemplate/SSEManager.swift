//
//  SSEManager.swift
//  ServerSentEventTemplate
//
//  Created by 김재민 on 2021/06/29.
//

import Foundation

public enum SSEManagerState {
    case connecting
    case connected
    case disconnected
    case error
}

public protocol SSEManagerDelegate {
    func sseManager(didChange state: SSEManagerState)
}

@objc public protocol SSEManagerDataTaskDelegate {
    @objc optional func sseManager(didReceive error: Error?)
    @objc optional func sseManager(didReceivedData value: Data)
    @objc optional func sseManager(didReceivedString value: String)
    @objc optional func sseManager(didReceivedDictionary value: [String : String])
}

public protocol SSEPolicy {
    var session: URLSession? { get }
    
    var dataTask: URLSessionDataTask? { set get }
    
    var url: URL? { set get }
    
    var state: SSEManagerState { set get }
    
    var delegate: SSEManagerDelegate? { set get }
    var dataTaskDelegate: SSEManagerDataTaskDelegate? { set get }
    
}

extension SSEPolicy {
    mutating public func setUrl(url: String) {
        guard let parseUrl = URL(string: url) else {
            return
        }
        self.url = parseUrl
    }
    
    mutating public func setUrl(url: URL) {
        self.url = url
    }
    
    mutating public func connect() {
        guard let url = self.url else { return }
        disconnect()
        
        dataTask = session?.dataTask(with: url)
        dataTask?.resume()
        
        state = .connecting
        delegate?.sseManager(didChange: .connecting)
    }
    
    mutating public func disconnect() {
        dataTask?.cancel()
        dataTask = nil
        
        if state == .connected || state == .connecting {
            delegate?.sseManager(didChange: .disconnected)
        }
    }
    
}

open class SSEManager: NSObject, SSEPolicy {
    public var session: URLSession?
    
    public var dataTask: URLSessionDataTask?
    
    public var url: URL?
    
    public var state: SSEManagerState = .disconnected
    
    public var delegate: SSEManagerDelegate?
    public var dataTaskDelegate: SSEManagerDataTaskDelegate?
    
    public override init() {
        super.init()
        
        setSession()
    }
    
    public init(url: String) {
        super.init()
        
        if let url = URL(string: url)  {
            self.url = url
        }
        
        setSession()
    }
    
    public init(url: URL) {
        super.init()
        self.url = url
        setSession()
    }
    
    private func setSession() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }
    
    private func convertDataStringToDictionary(serverSentEventData string: String) -> [String : String] {
        var resultDict: [String : String] = [:]
        let removedHttpString = string.replacingOccurrences(of: "\r", with: "")
        let slicedEventArray = removedHttpString.components(separatedBy: "data: ").first
        var slicedDataArray = removedHttpString.components(separatedBy: "data: ")
        slicedDataArray.removeFirst()
        
        if let eventString = slicedEventArray?.components(separatedBy: "event: ").last {
            resultDict.updateValue(eventString, forKey: "event")
        }
        
        for data in slicedDataArray {
            resultDict.updateValue(data, forKey: "data")
        }
        
        return resultDict
    }
}

extension SSEManager: URLSessionDelegate, URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        dataTaskDelegate?.sseManager?(didReceive: error)
        delegate?.sseManager(didChange: .error)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if state == .connecting {
            state = .connected
            delegate?.sseManager(didChange: .connected)
        }
        guard let modelData = String(data: data, encoding: .utf8) else {
            dataTaskDelegate?.sseManager?(didReceivedData: data)
            return
        }
        let resultDict = convertDataStringToDictionary(serverSentEventData: modelData)
        
        dataTaskDelegate?.sseManager?(didReceivedString: modelData)
        dataTaskDelegate?.sseManager?(didReceivedDictionary: resultDict)
    }
}
