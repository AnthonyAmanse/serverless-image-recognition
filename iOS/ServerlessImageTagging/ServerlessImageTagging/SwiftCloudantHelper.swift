//
//  SwiftCloudantHelper.swift
//  ServerlessImageTagging
//
//  Created by Joe Anthony Peter Amanse on 6/25/18.
//  Copyright © 2018 Joe Anthony Peter Amanse. All rights reserved.
//

import UIKit
import SwiftCloudant

class SwiftCloudantHelper {
    let dbName: String
    let dbNameProcessed: String
    let client: CouchDBClient
    
    init(cloudantURL: String, username: String, password: String, dbName: String, dbNameProcessed: String) {
        self.dbName = dbName
        self.dbNameProcessed = dbNameProcessed
        self.client = CouchDBClient(url: URL(string: cloudantURL)!, username: username, password: password)
//        let db = CreateDatabaseOperation(name: dbName) { response, info, error in
//            if let error = error {
//                print("Error creating database \(error)")
//            }
//        }
//        let dbprocessed = CreateDatabaseOperation(name: dbNameProcessed) { response, info, error in
//            if let error = error {
//                print("Error creating database \(error)")
//            }
//        }
//        client.add(operation: db)
//        client.add(operation: dbprocessed)
    }
    
    func saveImage(_ image: UIImage, name: String, completion: (([String : Any]) -> ())?) {
        let create = PutDocumentOperation(body: ["name":name], databaseName: self.dbName) { response, httpInfo, error in
            if let error = error {
                print("Error in saving document \(error)")
            } else if let response = response {
                
                // then attach image
                let putAttachment = PutAttachmentOperation(name: "image", contentType: "image/jpeg", data: UIImageJPEGRepresentation(image, 1.0)!, documentID: response["id"] as! String, revision: response["rev"] as! String, databaseName: self.dbName) { response, httpInfo, error in
                    if let error = error {
                        print("Error in adding image \(error)")
                    } else if let response = response {
                        completion?(response)
                    }
                }
                self.client.add(operation: putAttachment)
            }
        }
        self.client.add(operation: create)
    }
    
    func saveDocument(_ image: UIImage, name: String, completion: (([String : Any]) -> ())?) {
        let create = PutDocumentOperation(body: ["name": name, "_attachments":["image":["content_type":"image/jpeg","data":UIImageJPEGRepresentation(image, 1.0)!.base64EncodedString()]]], databaseName: self.dbName) { response, httpInfo, error in
            if let error = error {
                print("Error in saving document \(error)")
            } else if let response = response {
                completion?(response)
            }
        }
        self.client.add(operation: create)
    }
    
    func getTags(_ id: String, tries: Int? = 0, completion: (([Any]) -> ())?) {
        let get = GetDocumentOperation(id: id, databaseName: self.dbNameProcessed) {
            response, httpInfo, error in
            if let error = error {
                print("Error getting document id: \(id) with error: \(error)")
                if tries! < 500 {
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.getTags(id, tries: tries! + 1, completion: completion)
                    }
                }
            } else if let response = response {
                if let watsonResults = response["watsonResults"] {
                    if watsonResults is Array<Any> {
                        let classes = (watsonResults as! Array<Any>)[0] as! [String: Any]
                        if classes["classes"] is Array<Any> {
                            completion?(classes["classes"] as! Array<Any>)
                        }
                    }
                }
            }
        }
        self.client.add(operation: get)
    }

}
