//
//  ViewController.swift
//  ChatApp
//
//  Created by Etwan on 11/07/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var chatTableView    : UITableView!
    @IBOutlet weak var messageTextLbl   : UITextField!
    @IBOutlet weak var sendButton       : UIButton!
    @IBOutlet weak var msjBottomCons    : NSLayoutConstraint!
    @IBOutlet weak var btnBottomCons    : NSLayoutConstraint!
    
    private var messages                : [ChatMessage] = []
    private let userID                  = UserDefaults.standard.string(forKey: "userId") ?? UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initSetup()
    }
    
    private func initSetup(){
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: "MessageSend", bundle: nil), forCellReuseIdentifier: "MessageSend")
        chatTableView.register(UINib(nibName: "MessageRecieved", bundle: nil), forCellReuseIdentifier: "MessageRecieved")
        
        self.messageTextLbl.delegate = self
        self.messageTextLbl.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if UserDefaults.standard.string(forKey: "userId") == nil {
            UserDefaults.standard.set(self.userID, forKey: "userId")
        }
        
        FirebaseController.shared.loadMessage { [weak self] messages in
            self!.messages = messages ?? [ChatMessage]()
            self!.chatTableView.reloadData()
        } callbackError: {
            print("Error")
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        self.sendButton.imageView?.image = (messageTextLbl.text!.isEmpty) ? UIImage(systemName: "paperplane") : UIImage(systemName: "paperplane.fill")
        print(self.messageTextLbl.text?.count)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("Se muestra teclado")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            msjBottomCons.constant -= (keyboardSize.height - 20)
            btnBottomCons.constant -= (keyboardSize.height - 20)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        msjBottomCons.constant = 0
        btnBottomCons.constant = 0
    }

    @IBAction func sendActionButton(_ sender: Any) {
        self.messageTextLbl.text = FirebaseController.shared.sendMessage(self.messageTextLbl.text, self.userID)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages[indexPath.row].userID == self.userID {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageSend") as? MessageSend {
                cell.message.text = messages[indexPath.row].message
                cell.time.text = messages[indexPath.row].time
                return cell
            }
        }else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageRecieved") as? MessageRecieved {
                cell.message.text = messages[indexPath.row].message
                cell.time.text = messages[indexPath.row].time
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1024
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
    
}
