//
//  SpeechRecognizer.swift
//  ScanningApp
//
//  Created by Amor on 2021/12/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import Speech
import UIKit
import ARKit

class SpeechRecognizer{
    // MARK: Properties
    
    static let recordingEndNotification = Notification.Name("RecordingEndNotification")
    static let recordingEndUserInfo = "SpeechRecognizer.recordingEndUserInfo"
    
    
    // The speech recogniser used by the controller to record the user's speech.
    private let speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        
    // The current speech recognition request. Created when the user wants to begin speech recognition
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        
    // The current speech recognition task. Created when the user wants to begin speech recognition.
    private var recognitionTask: SFSpeechRecognitionTask?
        
    // The audio engine used to record input from the microphone.
    private let audioEngine = AVAudioEngine()
    
    private var pressDown: Bool? {
        willSet(newValue){
            if newValue != pressDown {
                if newValue == true {
                    startRecording()
                } else if newValue == false {
                    stopRecording()
                }
            }
        }
    }
    
    var spokenText = "" {
        willSet(newValue) {
            print("spokenText: \(spokenText)")
            
        }
    }
    
    private var sceneView: ARSCNView
    
    init(sceneView: ARSCNView){
        self.sceneView = sceneView
    }
    
    // MARK: SFAudioTranscription
    private func startRecording() {
        // setup recongizer
        guard speechRecogniser.isAvailable else {
            // Speech recognition is unavailable, so do not attempt to start.
            return
        }
        
        // make sure we have permission
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            SFSpeechRecognizer.requestAuthorization({ (status) in
                // Handle the user's decision
                print(status)
            })
            return
        }
        
        
        // setup audio
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            fatalError("Audio engine could not be setup")
            
        }

        if recognitionRequest == nil {
            // setup reusable request (if not already)
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            // perform on device, if possible
            // NOTE: this will usually limit the voice analytics results
            if speechRecogniser.supportsOnDeviceRecognition {
                print("Using on device recognition, voice analytics may be limited.")
                recognitionRequest?.requiresOnDeviceRecognition = true
            }else{
                print("Using server for recognition.")
            }
        }
        

        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            // Handle error
            return
        }
        
        recognitionTask = speechRecogniser.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
            if let result = result {
                spokenText = result.bestTranscription.formattedString
            }
            
            if result?.isFinal ?? (error != nil) {
                // this will remove the listening tap
                // so that the transcription stops
                inputNode.removeTap(onBus: 0)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do{
            try audioEngine.start()
        }
        catch {
            fatalError("Audio engine could not start")
        }
    }
    
    private func stopRecording() {
        if audioEngine.isRunning{
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
    }
    
    // when a long press gesture is recognized, call this method.
    func start() {
        print("startRecording")
        // I use this in place of startRecording, because long press gesture recognizer will call this method multiple times
        pressDown = true
    }
    
    func stop() {
        // add this code to interlock the startRecording and stopRecording state
        // otherwise, it'll be a disorder to display the reply message
        guard pressDown == true && self.spokenText != "" else { return }
        print("stopRecording ")
        pressDown = false
        // after issue a message, it should be set to "", otherwise the same message may send N times by misbutton
        let message = self.spokenText
        self.spokenText = ""
        // display the user's speech
        ViewController.instance?.displayMessage(message, expirationTime: 4)
        
        NotificationCenter.default.post(name: SpeechRecognizer.recordingEndNotification,
                                        object: self,
                                        userInfo: [SpeechRecognizer.recordingEndUserInfo: message]
        )
    }
    
    
    
}
