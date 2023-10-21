//
//  SYMScript.swift
//  SYM-Helper
//

import Foundation

class SYMScript: NSObject, URLSessionDelegate {
    func get(scriptURL: String, updateDisplay: Bool = true, completion: @escaping (_ authResult: String) -> Void) {
//        print("enter getScript")
        print("[SYMScript.get] script source: \(scriptURL)")
        var responseData = ""
        URLCache.shared.removeAllCachedResponses()
        //        let scriptUrl      = URL(string: "\(scriptSource)")
        let scriptUrl      = URL(string: "\(scriptURL)")
        let configuration  = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10
        var request        = URLRequest(url: scriptUrl!)
        request.httpMethod = "GET"
        configuration.httpAdditionalHeaders = ["User-Agent" : AppInfo.userAgentHeader]
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { [self]
            (data, response, error) -> Void in
            session.finishTasksAndInvalidate()
            if let httpResponse = response as? HTTPURLResponse {
                if httpSuccess.contains(httpResponse.statusCode) {
                    print("statusCode: \(httpResponse.statusCode)")
                    
                    if let _ = String(data: data!, encoding: .utf8) {
                        responseData = String(data: data!, encoding: .utf8)!
//                        writeToLog.message(stringOfText: "[CreateEndpoints] \n\nfull response from create:\n\(responseData)") }
                        print("[SYMScript] done fetching script")
//                        print("[SYMScript] script: \(responseData)")
                        
    //                    print("getScript: \(symScript)")   (.|\n|\r)
    //                    if let versionLineRange = responseData.range(of:"#   Version [0-9](.*?)[0-9],(.*?)\\)", options: .regularExpression) {
                        if let versionLineRange = responseData.range(of:"scriptVersion=\"[0-9](.*?)\"", options: .regularExpression) {
//                        if let versionLineRange = responseData.range(of:"#   Version [0-9](.|[0-9]|\\.).[0-9](.|[0-9]|\\.).[0-9](.|[0-9]|\\,)", options: .regularExpression) {
                            let versionLine = responseData[versionLineRange]
//                            let versionString = versionLine.replacing("#   Version ", with: "").dropLast()
                            let versionString = versionLine.replacing("scriptVersion=\"", with: "").dropLast()
                            print("[SYMScript.get] scriptVersion: \(String(describing: versionString))")
                            scriptVersion = toTuple(versionString: String(versionString))
                            if updateDisplay {
                                NotificationCenter.default.post(name: .updateScriptVersion, object: self)
                            }
                        } else {
                            print("[SYMScript.get] versionLine not found")
                        }
                        
                    } else {
                        writeToLog.message(stringOfText: "\n[getScript] No data was returned from post/put.")
                    }
                    completion(responseData)
                    return
                }
            } else {
                print("[SYMScript.get] could not read response or no response")
            }
            completion(responseData)
        })
        task.resume()
    }
    
    private func toTuple(versionString: String) -> (Int,Int,Int) {
//        var theArray = [0,0,0]
        let verionArray = versionString.components(separatedBy: ".")
        
        return((Int(verionArray[0]) ?? 0,Int(verionArray[1]) ?? 0,Int(verionArray[2]) ?? 0))
    }
}
