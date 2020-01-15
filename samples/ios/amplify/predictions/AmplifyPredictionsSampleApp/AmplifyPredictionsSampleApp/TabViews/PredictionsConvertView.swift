//
//  PredictionsInterpretView.swift
//  AmplifyPredictionsSampleApp
//
//  Created by Roy, Jithin on 10/23/19.
//  Copyright © 2019 AWS. All rights reserved.
//

import SwiftUI
import Amplify
import AVKit
import Combine

struct PredictionsConvertView: View {

    @State private var userInput: String = ""
    @State private var translatedText: String = ""
    @State private var showingConvertActionSheet = false
    @State private var avPlayer: AVAudioPlayer!
    @ObservedObject var audioRecorder: AudioRecorder
    
    init() {
        audioRecorder = AudioRecorder()
    }

    func translateText(text:String) {
        _ = Amplify.Predictions.convert(textToTranslate: text,
                                        language: .english,
                                        targetLanguage: .italian,
                                        options: PredictionsTranslateTextRequest.Options(),
                                        listener: { (event) in
                                            
                                            switch event {
                                            case .completed(let result):
                                                let castedResult = result as! TranslateTextResult
                                                print(castedResult.text)
                                                self.translatedText = castedResult.text
                                            default:
                                                print("")
                                                
                                                
                                            }
        })
    }
    
    func textToSpeech(text: String) {
        let options = PredictionsTextToSpeechRequest.Options(voiceType: .englishFemaleIvy, pluginOptions: nil)
     
        _ = Amplify.Predictions.convert(textToSpeech: text, options: options, listener: { (event) in
            
            switch event {
            case .completed(let result):
                let castedResult = result as! TextToSpeechResult
                print(castedResult.audioData)
                self.avPlayer = try? AVAudioPlayer(data: castedResult.audioData)
                self.avPlayer?.play()
            default:
                print("")
                
                
            }
        })
    }
    
    var convertActionSheet: ActionSheet {
        ActionSheet(title: Text("Action Sheet"), message: Text("Choose Option"), buttons: [
            .default(Text("Translate Text"), action: {self.translateText(text: self.userInput)}),
            .default(Text("Text to Speech"), action: {self.textToSpeech(text: self.userInput)}),
            .destructive(Text("Cancel"))
        ])
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if audioRecorder.recording == false {
                    Button(action: {self.audioRecorder.startRecording()}) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                } else {
                    Button(action: {self.audioRecorder.stopRecording()}) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                }
                
                TextField("Enter text to convert", text: $userInput)
                    .padding(.all)
                Button(action: {
                    self.showingConvertActionSheet.toggle()
                }) {
                    HStack {
                        Spacer()
                        Text("Convert")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 10.0)
                .background(Color.blue)
                .padding(.horizontal, 50)
                Text(translatedText).padding(.all).foregroundColor(.white)
                Text(audioRecorder.transcription).padding(.all).foregroundColor(.white)
                
            }.padding(.horizontal, 15)
                .actionSheet(isPresented: $showingConvertActionSheet, content: {
                    self.convertActionSheet
                })
                .navigationBarTitle(Text("Convert"))
        }
    }
    
}

struct PredictionsConvertView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionsConvertView()
        .padding()
    }
}
