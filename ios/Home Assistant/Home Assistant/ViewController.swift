//
//  ViewController.swift
//  Home Assistant
//
//  Created by khongks on 11/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import UIKit
import JSQMessagesViewController

import ConversationV1
import TextToSpeechV1
import SpeechToTextV1

import CocoaMQTT
import BluemixObjectStorage

class ViewController: JSQMessagesViewController {
  
  // name of app
  let name = "Home Assistant"
  
  // JSQMessageViewController stuff
  let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(R: 0xEE, G: 0xEE, B: 0xFF))
  let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(R: 0xA9, G: 0xFD, B: 0xAC))
  var messages = [JSQMessage]()
  
  // WatsonSDK Objects
  var conversation: Conversation!
  var context: Context!
  var textToSpeech: TextToSpeech!
  //var speechToText: SpeechToText!
  var speechToTextSession: SpeechToTextSession!
  
  let eventTopic = "iot-2/type/\(Credentials.DevType)/id/\(Credentials.DevId)/evt/+/fmt/json"
  
  // Audio Player
  // A note about AVAudioPlayer: The AVAudioPlayer object will stop playing
  // if it falls out-of-scope. Therefore, it's important to declare it as a
  // property or otherwise keep it in-scope beyond the completion handler.
  var audioPlayer = AVAudioPlayer()
  
  // Object Storage client
  var objectStorage: ObjectStorage!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.setupUI()
    self.setupDismissKeyboard()
    self.setupWatsonIOT()
    self.setupWatson()
    self.setupObjectStorage()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}


// Handle keyboards
extension ViewController {
  
  func setupDismissKeyboard() {
    //Looks for single or multiple taps.
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
    //tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  //Calls this function when the tap is recognized.
  func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
}
