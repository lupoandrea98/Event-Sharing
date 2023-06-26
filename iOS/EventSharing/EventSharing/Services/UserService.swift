//
//  UserService.swift
//  EventSharing
//
//  Created by certimeter on 13/04/23.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

final class UserService {
    
    private let jsonEncoder = JSONEncoder()
    private var generalURL = "http://10.0.100.84:8080/eventsharing/api"
    
    func getUsersList(userId: String, completion: @escaping(_ users:[User]) -> ()) {
        let url: URL = URL(string: "\(generalURL)/user/list/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode - getUserInfo: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            do{
                let userData = try JSONDecoder().decode([User].self, from: data)
                DispatchQueue.main.async {
                    completion(userData)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getUserInfo(userId: String, completion: @escaping(_ user: User) ->()) {
        let url: URL = URL(string: "\(generalURL)/user/info/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode - getUserInfo: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            do{
                let userData = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    completion(userData)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getUserName(userId: String, completion: @escaping(_ username: String) ->()) {
        let url: URL = URL(string: "\(generalURL)/user/username/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            //let username = try JSONDecoder().decode(String.self, from: data)
            if let username = String(data: data, encoding: .utf8) {
                print(username)
                DispatchQueue.main.async {
                    completion(username)
                }
            }            
        }
        task.resume()
    }
    
    func updateUserAPI(user: [String: String], completion: @escaping(_ result: String) -> ()) {
        let url: URL = URL(string: "\(generalURL)/user/update")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonUser = try? jsonEncoder.encode(user)
        request.httpBody = jsonUser
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta utente \(error.debugDescription)")
                return
            }
            
            if let responseData = String(data: data, encoding: .utf8) {
                print("responsedata: \(responseData)")
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Error Update")
                }
            }
          
        }
        task.resume()
        
        
    }
    
    func updateUserInfo(_ userInfo: User?, username: String, email: String, oldPassword: String, password: String, image: UIImage?, completion: @escaping(_ result: String) -> ()) {
        guard let userId = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'userId")
            return
        }
        
        var user: [String: String]

        if image != nil {
            guard let imageData = image!.pngData()?.base64EncodedString() else {
                print("error during image conversion to string")
                return
            }
            user = [
                "id": userId,
                "email": email,
                "username": username,
                "image": imageData
            ]
        } else {
            user = [
                "id": userId,
                "email": email,
                "username": username,
                "image": ""
            ]
        }
        
        //Devo evitare questa chiamata se password e email non sono cambiate
        if(email != userInfo?.email || oldPassword != "") {
            //Necessario un login per compiere le operazioni di modifica
            Auth.auth().signIn(withEmail: userInfo?.email ?? "", password: oldPassword) {
                (_ , error) in
                if let error = error {
                    print("Firebase autentication error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(error.localizedDescription)
                    }
                    return
                } else {
                    //Firebasechanges
                    if email != userInfo?.email {
                        //update email
                        Auth.auth().currentUser?.updateEmail(to: email) {
                            error in
                            if let error = error {
                                print(error)
                                DispatchQueue.main.async {
                                    completion(error.localizedDescription)
                                }
                                return
                            } else {
                                self.updateUserAPI(user: user) {
                                    result in
                                    DispatchQueue.main.async {
                                        completion(result)
                                    }
                                }
                            }
                        }
                    }
                    if oldPassword != "" && password != "" && oldPassword != password{
                        //Update password
                        Auth.auth().currentUser?.updatePassword(to: password) {
                            error in
                            if let error = error {
                                print(error)
                                DispatchQueue.main.async {
                                    completion("Unable to update the password")
                                }
                                return
                            } else {
                                self.updateUserAPI(user: user) {
                                    result in
                                    DispatchQueue.main.async {
                                        completion(result)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            updateUserAPI(user: user) {
                result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    // MARK: Send invitation
    func sendInvitation(_ userId: String, _ userEmail: [String], _ eventId: String, completion: @escaping(_ result: String) -> ()) {
        let url: URL = URL(string: "\(generalURL)/invitation/invite/\(userId)/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEmails = try? jsonEncoder.encode(userEmail)
        request.httpBody = jsonEmails
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta utente \(error.debugDescription)")
                return
            }
            
            if let responseData = String(data: data, encoding: .utf8) {
                print("responsedata: \(responseData)")
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Unable to made invitation")
                }
            }
          
        }
        task.resume()
    }
    
    // MARK: Delete Invitation
    
    func deleteInvitation(_ invitationId: String, completion: @escaping(_ result: String) -> ()) {
        let url: URL = URL(string: "\(generalURL)/invitation/delete/\(invitationId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode deleteInvitation: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta utente \(error.debugDescription)")
                return
            }
            
            if let responseData = String(data: data, encoding: .utf8) {
                print("responsedata: \(responseData)")
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Error Update")
                }
            }
          
        }
        task.resume()
    }
    
    
    // MARK: Maded Invitations
    func madedInvitation(_ userId: String, completion: @escaping(_ result: [Invitation]) -> ()) {
        
        let url: URL = URL(string: "\(generalURL)/invitation/getMaded/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode madedInvitation: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta utente \(error.debugDescription)")
                return
            }
            
            do{
                print(data.description)
                let invitations = try JSONDecoder().decode([Invitation].self, from: data)
                DispatchQueue.main.async {
                    completion(invitations)
                }
            }catch {
                print(error)
            }
          
        }
        task.resume()
    }
    
    // MARK: Recieved Invitations
    
    func recievedInvitation(_ userId: String, completion: @escaping(_ result: [Invitation]) -> ()) {
        
        let url: URL = URL(string: "\(generalURL)/invitation/getRecieved/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode recievedInvitation: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta utente \(error.debugDescription)")
                return
            }
            
            do{
                print(data.description)
                let invitations = try JSONDecoder().decode([Invitation].self, from: data)
                DispatchQueue.main.async {
                    completion(invitations)
                }
            }catch {
                print(error)
            }
          
        }
        task.resume()
    }
    
    // MARK: mark as read
    
    func setAsRead(_ invitationId: String, completion: @escaping(_ result: String) -> ()) {
        
        let url: URL = URL(string: "\(generalURL)/invitation/setAsRead/\(invitationId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode setAsRead: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta utente \(error.debugDescription)")
                return
            }
            
            if let responseData = String(data: data, encoding: .utf8) {
                print("responsedata: \(responseData)")
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Error Update")
                }
            }
          
        }
        task.resume()
    }
    
    //MARK: Set invite state
    func setInvitationState(_ invitationId: String, _ state: String, completion: @escaping(_ result: String) -> ()) {
        
        let url: URL = URL(string: "\(generalURL)/invitation/setState/\(invitationId)/\(state)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode setInvitationState: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta utente \(error.debugDescription)")
                return
            }
            
            if let responseData = String(data: data, encoding: .utf8) {
                print("responsedata: \(responseData)")
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Error Update")
                }
            }
          
        }
        task.resume()
    }
    
}
