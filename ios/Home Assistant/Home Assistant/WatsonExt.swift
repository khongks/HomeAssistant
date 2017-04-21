//
//  WatsonExt.swift
//  Home Assistant
//
//  Created by khongks on 16/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import Foundation
import UIKit

import ConversationV1
import TextToSpeechV1
import SpeechToTextV1
import AVFoundation

extension ViewController {
  
  func setupWatson() {
    
    // Initialize Watson Conversation
    conversation = Conversation(username: Credentials.ConversationUsername, password: Credentials.ConversationPassword, version: "2017-03-12")
    let failure = { (error: Error) in print(error) }
    conversation?.message(withWorkspace: Credentials.ConversationWorkspaceID, failure: failure) {
      response in
      print("output.text: \(response.output.text)")
      self.didReceiveConversationResponse(response.output.text)
      self.context = response.context
    }
    // Initialize Watson TTS
    textToSpeech = TextToSpeech(username: Credentials.TextToSpeechUsername, password: Credentials.TextToSpeechPassword)
    
    // Initialize Watson STT
    speechToTextSession = SpeechToTextSession(username: Credentials.SpeechToTextUsername, password: Credentials.SpeechToTextPassword)
    // define callbacks
    speechToTextSession?.onResults = onResults
  }
  
  // Callback for speech recognition
  func onResults(results: SpeechRecognitionResults) {
    self.inputToolbar.contentView.textView.text = results.bestTranscript
    self.inputToolbar.toggleSendButtonEnabled()
  }
  
  func sttStartStreaming() {
    // define settings
    var settings = RecognitionSettings(contentType: .opus)
    settings.continuous = true
    settings.interimResults = true
    
    self.speechToTextSession?.connect()
    self.speechToTextSession?.startRequest(settings: settings)
    self.speechToTextSession?.startMicrophone()
  }
  
  func sttStopStreaming() {
    self.speechToTextSession?.stopMicrophone()
    self.speechToTextSession?.stopRequest()
    // No need to disconnect -- the connection will timeout if the microphone
    // is not used again within 30 seconds. This avoids the overhead of
    // connecting and disconnecting the session with every press of the
    // microphone button.
    //self.speechToTextSession?.disconnect()
    //self.speechToText?.stopRecognizeMicrophone()
  }
  
  func ttsSynthesize(_ sentence: String) {
    // Synthesize the text
    let failure = { (error: Error) in print(error) }
    self.textToSpeech?.synthesize(sentence, voice: SynthesisVoice.gb_Kate.rawValue, failure: failure) { data in
      self.audioPlayer = try! AVAudioPlayer(data: data)
      self.audioPlayer.prepareToPlay()
      self.audioPlayer.play()
    }
  }
  
  func conversationRequestResponse(_ text: String) {
    let failure = { (error: Error) in print(error) }
    let request = MessageRequest(text: text, context: self.context)
    self.conversation?.message(withWorkspace: Credentials.ConversationWorkspaceID,
                               request: request,
                               failure: failure) {
                                response in
                                print(response.output.text)
                                self.didReceiveConversationResponse(response.output.text)
                                self.context = response.context
                                // issue command based on intents and entities
                                print("appl_action: \(response.context.json["appl_action"])")
                                self.issueCommand(intents: response.intents, entities: response.entities)
    }
  }
  
  func issueCommand(intents: [Intent], entities: [Entity]) {
    
    for intent in intents {
      print("intent: \(intent.intent), confidence: \(intent.confidence) ")
    }
    for entity in entities {
      print("entity: \(entity.entity), value: \(entity.value)")
    }
    
    for intent in intents {
      if intent.confidence > 0.9 {
        switch intent.intent {
        case "OnLight":
          let command = Command(action: "On", object: "Light", intent: intent.intent)
          sendToDevice(command, subtopic: "light")
        case "OffLight":
          let command = Command(action: "Off", object: "Light", intent: intent.intent)
          sendToDevice(command, subtopic: "light")
        case "TakePicture":
          let command = Command(action: "Take", object: "Picture", intent: intent.intent)
          sendToDevice(command, subtopic: "camera")
        default:
          print("No such command")
          return
        }
      }
    }
  }
}
