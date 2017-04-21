//
//  Command.swift
//  Home Assistant
//
//  Created by khongks on 16/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import Foundation

struct Command : JSONSerializable {
  
  let action: String
  let object: String
  let intent: String
}
