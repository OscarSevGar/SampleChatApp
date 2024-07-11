//
//  FirebaseController.swift
//  ChatApp
//
//  Created by Etwan on 11/07/24.
//

import Foundation
import FirebaseDatabase

class FirebaseController {
    
    static let shared       : FirebaseController = FirebaseController()
    private var messages    = [ChatMessage]()
    
    func loadMessage(callbackSuccess: @escaping (([ChatMessage]?)->Void), callbackError: @escaping (()->Void)) {
        let refDB = Database.database().reference()
        refDB.child("messages").observe(.childAdded) { [weak self] snapshot  in
            if let data = snapshot.value as? [String: String] {
                if let text = data["text"], let userId = data["userId"], let time = data["time"] {
                    self?.messages.append(ChatMessage(userID: userId, message: text, time: time))
                    callbackSuccess(self?.messages)
                }
            }else{
                callbackError()
            }
        }
    }
    
    func sendMessage(_ message: String?, _ userID : String) -> String {
        guard let message = message else { return "" }
        let refDB = Database.database().reference()
        let messageRef = refDB.child("messages").childByAutoId()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let messageData = ["text": "\(message)", "userId": "\(userID)", "time": "\(timeFormatter.string(from: Date()))"]
        messageRef.setValue(messageData)
        return ""
    }
}
