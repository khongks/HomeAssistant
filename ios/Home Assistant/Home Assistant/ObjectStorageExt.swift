//
//  ObjectStorageExt.swift
//  Home Assistant
//
//  Created by khongks on 16/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import Foundation
import UIKit
import BluemixObjectStorage

extension ViewController {
  
  func setupObjectStorage() {
    print("Region: \(Credentials.ObjectStorageRegion)")
    self.objectStorage = ObjectStorage(projectId: Credentials.ObjectStorageProjectId)
    objectStorage.connect(userId: Credentials.ObjectStorageUserId,
                          password: Credentials.ObjectStoragePassword,
                          region: Credentials.ObjectStorageRegion) {
                            error in
                            if let error = error {
                              print("objectstorage connect error :: \(error)")
                            } else {
                              print("objectstorage connect success")
                            }
    }
  }
  
  func downloadPictureFromObjectStorage(containername: String, objectname: String) {
    self.objectStorage.retrieve(container: containername) {
      error, container in
      if let error = error {
        print("retrieve container error :: \(error)")
      } else if let container = container {
        container.retrieve(object: objectname) {
          error, object in
          if let error = error {
            print("retrieve object error :: \(error)")
          } else if let object = object {
            print("retrieve object success :: \(object.name)")
            guard let data = object.data else {
              return
            }
            if let image = UIImage(data: data) {
              self.addPicture(image)
              self.didReceiveConversationResponse(["Picture taken"])
            }
          } else {
            print("retrieve object exception")
          }
        }
      } else {
        print("retrieve container exception")
      }
    }
  }
}
