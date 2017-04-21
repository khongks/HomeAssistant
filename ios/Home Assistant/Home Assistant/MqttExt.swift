//
//  MqttExt.swift
//  Home Assistant
//
//  Created by khongks on 16/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import Foundation

import CocoaMQTT
import SwiftyJSON

extension ViewController : CocoaMQTTDelegate {
  
  func setupWatsonIOT() {
    mqttClient.username = Credentials.WatsonIOTUsername
    mqttClient.password = Credentials.WatsonIOTPassword
    mqttClient.keepAlive = 60
    mqttClient.delegate = self
  }
  
  func sendToDevice(_ command: Command, subtopic: String) {
    if let json = command.toJSON() {
      let topic = "iot-2/type/\(Credentials.DevType)/id/\(Credentials.DevId)/cmd/\(subtopic)/fmt/json"
      let message = CocoaMQTTMessage(topic: topic, string: json)
      print("publish message \(json)")
      mqttClient.publish(message)
    }
  }
  
  //
  // Callback methods for CocoaMQTTDelegate
  //
  func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
    print("didConnect")
    mqttClient.subscribe(eventTopic)
  }
  func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
    print("didConnectAck")
  }
  func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
    print("didPublishMessage")
  }
  func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    print("didPublishAck")
  }
  func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
    print("didReceiveMessage: \(message.string)")
    var json : JSON = JSON.null
    if let message = message.string {
      json = JSON.init(parseJSON: message)
    } else {
      return  // do nothing
    }
    
    let cameraTopic = "iot-2/type/\(Credentials.DevType)/id/\(Credentials.DevId)/evt/camera/fmt/json"
    let lightTopic = "iot-2/type/\(Credentials.DevType)/id/\(Credentials.DevId)/evt/light/fmt/json"
    
    switch message.topic {
    case cameraTopic:
      if let objectname = json["d"]["objectname"].string {
        if let containername = json["d"]["containername"].string {
          self.downloadPictureFromObjectStorage(containername: containername, objectname: objectname)
        }
      }
      
    case lightTopic:
      if let status = json["d"]["status"].string {
        switch status {
        case "on":
          self.didReceiveConversationResponse(["Light is on"])
        case "off":
          self.didReceiveConversationResponse(["Light is off"])
        default:
          break
        }
      }
    default:
      break
    }
  }
  
  func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
    print("didSubscribeTopic")
  }
  func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    print("didUnsubscribeTopic")
  }
  func mqttDidPing(_ mqtt: CocoaMQTT) {
  }
  func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
  }
  func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
    print("mqttDidDisconnect \(err?.localizedDescription)")
  }
}
