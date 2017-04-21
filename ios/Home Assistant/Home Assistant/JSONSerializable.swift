//
//  JSONSerializable.swift
//  Home Assistant
//
//  Created by khongks on 16/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import Foundation

//: ### Defining the protocols
protocol JSONRepresentable {
  var JSONRepresentation: Any { get }
}

protocol JSONSerializable: JSONRepresentable {}

//: ### Implementing the functionality through protocol extensions
extension JSONSerializable {
  var JSONRepresentation: Any {
    var representation = [String: Any]()
    
    for case let (label?, value) in Mirror(reflecting: self).children {
      
      switch value {
        
      case let value as Dictionary<String, Any>:
        representation[label] = value as AnyObject
        
      case let value as Array<Any>:
        if let val = value as? [JSONSerializable] {
          representation[label] = val.map({ $0.JSONRepresentation as AnyObject }) as AnyObject
        } else {
          representation[label] = value as AnyObject
        }
        
      case let value:
        representation[label] = value as AnyObject
      }
    }
    return representation as Any
  }
}

extension JSONSerializable {
  func toJSON() -> String? {
    let representation = JSONRepresentation
    
    guard JSONSerialization.isValidJSONObject(representation) else {
      print("Invalid JSON Representation")
      return nil
    }
    
    do {
      let data = try JSONSerialization.data(withJSONObject: representation, options: [])
      
      return String(data: data, encoding: .utf8)
    } catch {
      return nil
    }
  }
}
