//
//  Conversation.swift
//  Tutable
//
//  Created by Rohit Saini on 04/10/18.
//  Copyright © 2018 Keyur. All rights reserved.
//

import Foundation



import Foundation
import UIKit
import Firebase

class Conversation {
    
    //MARK: Properties
    let user: USER
    var lastMessage: Messages
    
    //MARK: Methods
    class func showConversations(completion: @escaping ([Conversation]) -> Swift.Void) {
        if let currentUserID = AppModel.shared.currentUser.id {
            var conversations = [Conversation]()
            Database.database().reference().child("users").child(currentUserID).child("conversations").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    let fromID = snapshot.key
                    let values = snapshot.value as! [String: String]
                    let location = values["location"]!
                    USER.info(forUserID: fromID, completion: { (user) in
                        let emptyMessage = Messages.init(type: .text, content: "loading", owner: .sender, timestamp: 0, isRead: true)
                        let conversation = Conversation.init(user: user, lastMessage: emptyMessage)
                        conversations.append(conversation)
                        conversation.lastMessage.downloadLastMessage(forLocation: location, completion: {
                            completion(conversations)
                        })
                    })
                }
            })
        }
    }
    
    //MARK: Inits
    init(user: USER, lastMessage: Messages) {
        self.user = user
        self.lastMessage = lastMessage
    }
}

