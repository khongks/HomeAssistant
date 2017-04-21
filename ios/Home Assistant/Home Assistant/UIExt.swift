//
//  UIExt.swift
//  Home Assistant
//
//  Created by khongks on 11/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import Foundation
import JSQMessagesViewController

extension ViewController  {
  
  func setupUI() {
    self.title = self.name
    self.senderId = UIDevice.current.identifierForVendor?.uuidString
    self.senderDisplayName = UIDevice.current.identifierForVendor?.uuidString
    
    JSQMessagesCollectionViewCell.registerMenuAction(#selector(synthesize(sender:)))
    
    // Create mic button
    let microphoneImage = UIImage(named:"microphone")!
    let microphoneButton = UIButton(type: .custom)
    microphoneButton.setImage(microphoneImage, for: .normal)
    microphoneButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    self.inputToolbar.contentView.leftBarButtonItem = microphoneButton
    
    // Add press and release mic button
    microphoneButton.addTarget(self, action:#selector(didPressMicrophoneButton), for: .touchDown)
    microphoneButton.addTarget(self, action:#selector(didReleaseMicrophoneButton), for: .touchUpInside)
    
    setAudioPortToSpeaker()
  }
  
  //
  // User Inputs functions
  //
  
  // Called when microphone button is pressed
  func didPressMicrophoneButton(sender: UIButton) {
    let microphonePressedImage = UIImage(named:"microphone_pressed")!
    sender.setImage(microphonePressedImage, for: .normal)
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    // Clear the input text
    self.inputToolbar.contentView.textView.text = ""
    // speech-to-text startStreaming
    sttStartStreaming()
  }
  
  // Called when microphone button is released
  func didReleaseMicrophoneButton(sender: UIButton){
    let microphoneImage = UIImage(named:"microphone")!
    sender.setImage(microphoneImage, for: .normal)
    // speech-to-text stop streaming
    self.sttStopStreaming()
  }
  
  // Called when send button is pressed
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    print("didPressSend \(text)")
    send(text)
  }
  
  // Need to override and provide dummy implementation
  override func didPressAccessoryButton(_ sender: UIButton!) {
  }
  
  //
  // Callback functions
  //
  
  // Called to show menu item 'Synthesize' when the text bubble is pressed.
  override func didReceiveMenuWillShow(_ notification: Notification!) {
    let menu : UIMenuController = notification.object as! UIMenuController
    menu.menuItems = [UIMenuItem.init(title: "Sythesize", action: #selector(synthesize(sender:)))]
  }

  // Called to get the number of messages
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.messages.count
  }
  
  // Returns the message at an indexPath
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    let data = self.messages[indexPath.row]
    return data
  }
  
  // Called when an item is selected
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  }
  
  // Called to render the text
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    let message = self.messages[indexPath.item]
    if !message.isMediaMessage {
      if message.senderId == self.senderId {
        cell.textView.textColor = UIColor(R: 0x72, G: 0x9B, B: 0x79)
      } else {
        cell.textView.textColor = UIColor(R: 0x47, G: 0x5B, B: 0x63)
      }
      let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor!, NSUnderlineStyleAttributeName: 1 as AnyObject]
      cell.textView.linkTextAttributes = attributes
    }
    return cell
  }
  
  // Called to an action can be performed
  override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    if action == #selector(synthesize(sender:)) {
      return true
    } else {
      return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }
  }
  
  // Called to perform the action
  override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    if action == #selector(synthesize(sender:)) {
      self.synthesize(sender: sender!)
    } else {
      super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
    }
  }

  // Called to deselect item
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    self.messages.remove(at: indexPath.row)
  }

  // Called to return a bubble decorator
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let data = messages[indexPath.row]
    switch(data.senderId) {
    case self.senderId:
      return self.outgoingBubble
    default:
      return self.incomingBubble
    }
  }
  
  // Used to display the label on top of the bubble
  // Returns the style of the attributed text for message bubble
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    if let message = firstMessage(at: indexPath) {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = NSTextAlignment.left
      let attrs = [
        NSParagraphStyleAttributeName: paragraphStyle,
        NSBaselineOffsetAttributeName: NSNumber(value: 0),
        NSForegroundColorAttributeName: UIColor(R: 0x1e, G: 0x90, B: 0xff)
      ]
      return NSAttributedString(string: message.senderDisplayName, attributes: attrs)
    } else {
      return nil
    }
  }
  
  // Used to display the label on top of the bubble
  // Returns the height of the attributed text for message bubble
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    if let _ = firstMessage(at: indexPath) {
      return kJSQMessagesCollectionViewCellLabelHeightDefault
    } else {
      return 0.0
    }
  }

  // Override so that there is no avatar image
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  //
  // Utility functions
  //
  // Send a message to Watson and add to the chat screen
  func send(_ text: String) {
    setAudioPortToSpeaker()
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), text: text)
    
    self.messages.append(message!)
    self.finishSendingMessage(animated: true)
    
    self.conversationRequestResponse(text)
  }
  
  // Called when receive a conversation response
  func didReceiveConversationResponse(_ response: [String]) {
    let sentence = response.joined(separator: " ")
    if sentence == "" { return }
    setAudioPortToSpeaker()
    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
    let message = JSQMessage(senderId: self.name, senderDisplayName: self.name, date: Date(), text: sentence)
    self.messages.append(message!)
    
    DispatchQueue.main.async {
      // text-to-speech synthesize
      self.ttsSynthesize(sentence)
      self.reloadMessagesView()
      self.finishReceivingMessage(animated: true)
    }
  }
  
  // Called to reload the view
  func reloadMessagesView() {
    self.collectionView?.reloadData()
  }
  
  // Called to synthesize speech from given text in the textView
  func synthesize(sender: Any) {
    let cell: JSQMessagesCollectionViewCell = sender as! JSQMessagesCollectionViewCell
    if let textView = cell.textView {
      ttsSynthesize(textView.text)
    }
  }
  
  // Called to add a picture into the chat window
  func addPicture(_ picture: UIImage) {
    setAudioPortToSpeaker()
    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
    let mediaItem = JSQPhotoMediaItem(image: picture)
    let message = JSQMessage(senderId: self.name, displayName: self.name, media: mediaItem)
    self.messages.append(message!)
    self.reloadMessagesView()
    self.finishReceivingMessage(animated: true)
  }

  // Call to set the audio port to speaker
  func setAudioPortToSpeaker() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
    } catch {
      print("error setting audio to speaker")
    }
  }
  
  // Return a message if it is the first message of the sender
  func firstMessage(at: IndexPath) -> JSQMessage! {
    let message = self.messages[at.item]
    if message.senderId == self.senderId {
      return nil
    }
    if at.item - 1 > 0 {
      let previousMessage = self.messages[at.item-1]
      if previousMessage.senderId == message.senderId {
        return nil
      }
    }
    return message
  }
}
