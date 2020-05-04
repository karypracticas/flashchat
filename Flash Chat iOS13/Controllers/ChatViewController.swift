    //
    //  ChatViewController.swift
    //  Flash Chat iOS13
    //
    //  Created by Angela Yu on 21/10/2019.
    //  Copyright © 2019 Angela Yu. All rights reserved.
    //

    import UIKit
    import Firebase

    class ChatViewController: UIViewController {
        
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var messageTextfield: UITextField!
        
        //Crear una referencia a la base de datos de Firestore
        let db = Firestore.firestore()
        
        //Dummie messages
        var messages: [Message] = []
        //var messages  : [Message] = [
            //Message(sender: "kary@gmail.com", body: "Hey"),
            //Message(sender: "yiya@gmail.com", body: "Hello"),
            //Message(sender: "kary@gmail.com", body: "What's up?")
        //]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            //Esconde el botón de Back
            navigationItem.hidesBackButton =  true
            title = K.appName
            
            tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
            
            loadMessages()
            
        }
        
        func loadMessages() {
            
                                                           //Ordenar como aparecen los mensajes
            db.collection(K.FStore.collectionName)
                .order(by: K.FStore.dateField)
                .addSnapshotListener { (querySnapshot, error) in
                    
                //Limpiar los datos dummies del array
                self.messages = []
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore ”\(e)")
                }else{
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                                let newMessage = Message(sender: messageSender, body: messageBody)
                                self.messages.append(newMessage)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        @IBAction func sendPressed(_ sender: UIButton) {
            
            if let messageBody = messageTextfield.text,let messageSender = Auth.auth().currentUser?.email{
                db.collection(K.FStore.collectionName).addDocument(data:
                    [K.FStore.senderField: messageSender,
                     K.FStore.bodyField: messageBody,
                     K.FStore.dateField: Date().timeIntervalSince1970
                ]) { (error) in
                if let e = error {
                        print("There was an issue saving data to firestore \(e)")
                                 }else {
                        print("Successfully data")
                    }
                }
                
                messageTextfield.text = ""
                
            }
        }
        
        @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
            //Código copiado de la pag de Firebase
            //firebase.google.com/docs/auth/ios/password-auth
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }

    extension ChatViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let message = messages[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
                as! MessageCell
            cell.label.text = message.body
            
            //Este es un mensaje del usuario actualmente logeado
            if message.sender == Auth.auth().currentUser?.email{
                cell.leftImageView.isHidden = true
                cell.rightImageView.isHidden = false
                //Cambiamos el color de la burbuja donde aparece el mensaje
                cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
                cell.label.textColor = UIColor(named: K.BrandColors.purple)
                
            }
            //Mensaje de otra persona
            else {
                cell.leftImageView.isHidden = false
                cell.rightImageView.isHidden = true
                //Cambiamos el color de la burbuja donde aparece el mensaje
                cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.purple)
                cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            }
            
            
            return cell
        }
    }
