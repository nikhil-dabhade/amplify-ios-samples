//
//  AudioRecorder.swift
//  AmplifyPredictionsSampleApp
//
//  Created by Stone, Nicki on 1/15/20.
//  Copyright © 2020 AWS. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import Amplify

class AudioRecorder: ObservableObject {
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var audioRecorder: AVAudioRecorder!
    
    var audioFilename: URL!
    
    var transcription = "" {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioFilename = documentPath.appendingPathComponent("\(UUID()).wav")
        //store filename on class to send to transcribe
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 8000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            
            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        recording = false
        transcribe()
    }
    
    func transcribe() {
        let options = PredictionsSpeechToTextRequest.Options(defaultNetworkPolicy: .auto, pluginOptions: nil)
//        let group = DispatchGroup()
//        group.enter()
           _ = Amplify.Predictions.convert(speechToText: audioFilename, options: options, listener: { (event) in
               
               switch event {
               case .completed(let result):
               
                print(result.transcription)
               // group.leave()
                DispatchQueue.main.async {
                   self.transcription = result.transcription
                }
               default:
                   print("")
                   
                   
               }
           })
       // sleep(3)
       // group.enter()
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url2 = documentPath.appendingPathComponent("D0C86DC2-529D-4660-9D4C-A6C6C20AA8AF.wav")
       
//           _ = Amplify.Predictions.convert(speechToText: url2, options: options, listener: { (event) in
//
//               switch event {
//               case .completed(let result):
//
//                print(result.transcription)
//                // group.leave()
//                DispatchQueue.main.async {
//                   self.transcription = result.transcription
//                }
//               default:
//                   print("")
//
//
//               }
//           })
        
//        group.notify(queue: .main) {
//            print("both done")
//        }
    }
}
