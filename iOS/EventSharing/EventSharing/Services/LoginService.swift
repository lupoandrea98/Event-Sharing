
import Foundation
import Firebase

final class LoginService {
    private let jsonEncoder = JSONEncoder()
    private var generalURL = "http://10.0.100.84:8080/eventsharing/api"
   
    func signInAPI(userId: String, username: String, email: String, image: UIImage,completion: @escaping(_ result: String) -> ()) {
        let url: URL = URL(string: "\(generalURL)/user/signin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.pngData()?.base64EncodedString() else {
            print("error during image conversion to string")
            return
        }

        let user: [String:String] = [
            "id": userId,
            "email": email,
            "username": username,
            "image": imageData
        ]
        
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
            
            //let responseData = try JSONDecoder().decode(String.self, from: data)
            if let responseData = String(data: data, encoding: .utf8) {
                print("responsedata: \(responseData)")
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Error SignIn")
                }
            }
          
        }
        task.resume()
    }
    
    func signIn(_ viewController:SignInViewController, username: String, email: String, pw: String, image: UIImage,completion: @escaping(_ result: String) ->()){
        Auth.auth().createUser(withEmail: email, password: pw) {
            (authResult, error) in
            if let error = error {
                print("Firebase createUser error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(error.localizedDescription)
                }
            }else if let user = authResult?.user{
                //l'utente è stato registrato con successo
                print("Utente registrato con successo: \(user.email ?? " ")")
                //ora posso effettuare l'accesso per prelevare il token
                Auth.auth().signIn(withEmail: email, password: pw) {
                    (result, error) in
                    if let error = error {
                        print("Firebase access error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(error.localizedDescription)
                        }
                    }else {
                        let firebaseUID = self.getUserToken()
                        UserDefaultsManager.shared.value = firebaseUID
                            self.signInAPI(userId: firebaseUID, username: username, email: email, image: image){
                            result in
                            if result != "true" {
                                Auth.auth().currentUser?.delete()
                            }
                            DispatchQueue.main.async {
                                completion(result)
                            }
                        
                        }
                    }
                    
                }
                
            }
        }
    }
    
    func getUserToken() -> String {
        guard let firebaseUID = Auth.auth().currentUser?.uid else {
            print("impossibile recuperare firebaseUID")
            return ""
        }
        return firebaseUID
    }
    
    func login(email: String, pw: String, completion: @escaping(_ result: String) -> ()) {
        Auth.auth().signIn(withEmail: email, password: pw) {
            (result, error) in
            if let error = error {
                print("Firebase autentication error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(error.localizedDescription)
                }
            }else{
                UserDefaultsManager.shared.value = self.getUserToken()
                DispatchQueue.main.async {
                    completion("true")
                }
            }
            
        }
    }
    
    func forgotPassword(_ email: String, completion: @escaping(_ result: (any Error)?) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email) {
             error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
}
