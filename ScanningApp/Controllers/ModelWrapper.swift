//
//  ModelWrapper.swift
//  ScanningApp
//
//  Created by Amor on 2021/12/4.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

// I set this protocol because I want to pass values to the viewController
protocol ModelWrapperDelegate: AnyObject{
    // if there will be a change in the prediction, then this method is called
    func predictionWillChange(value:String)
}

class ModelWrapper{
    
    weak var delegate: ModelWrapperDelegate?
    
    // Model Server address
    private var serverURL = ""
    // this key is for authentication, it will be stored in the cookie
    private let passKey = "h7hdg43scbmdTRY7hbv321szxcdOPd2mz1"
    // use chatId to identify if it's the same conversation
    private var chatId = ""
    
    private var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 20.0
        sessionConfig.timeoutIntervalForResource = 10.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig)
    }()
    
    // get the prediction result
    private var prediction: String = "" {
        willSet(newValue){
            // It's to delegate to viewController so that it can receive the event of value changed in order to update UI
            delegate?.predictionWillChange(value: newValue)
        }
    }
    
    init(url:String, delegate:ModelWrapperDelegate) {
        self.serverURL = url
        self.delegate = delegate
    }
    
    // reset the chatId so we can have thoroughly new conversation
    func resetChatId() {
        chatId = ""
    }
    
    func getPrediction(_ recordingContent:String, chatId:String){
        let baseURL = "\(serverURL)/GetNewAnswer"
        let postURL = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postURL!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["newInput":recordingContent, "chatId":chatId]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        // set cookies for authentication
        request.setValue("pass=\(passKey)", forHTTPHeaderField: "Cookie")
        request.httpShouldHandleCookies = true
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res)
                            }
                        }
                        else{ // no error we are aware of
                            
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            print("jsonDic: \(jsonDictionary)")
                            let response:String = jsonDictionary["response"]! as! String
                            self.prediction = response
                            self.chatId = jsonDictionary["chatId"]! as! String
                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
   
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }
    
}