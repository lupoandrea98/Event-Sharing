import Foundation
import MapKit

final class EventService: NSObject, URLSessionTaskDelegate{
    private let jsonEncoder = JSONEncoder()
    private var generalURL = "http://10.0.100.84:8080/eventsharing/api"
    
    func getEvents(completion: @escaping(_ events: [Event]) ->() ){
        let url: URL = URL(string: "\(generalURL)/event/getAll")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode getEvents: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                let delay = DispatchTimeInterval.seconds(10)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // Riprova la connessione al server
                    let homePresenter = PresenterManager.homePresenter
                    let controller = PresenterManager.homePresenter?.homeViewController
                    homePresenter?.getEvents(controller!)
                }
                return
            }
            do{
                print(data.description)
                let events = try JSONDecoder().decode([Event].self, from: data)
                DispatchQueue.main.async {
                    completion(events)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getEvent(_ eventId: Int, completion: @escaping(_ event: Event?) ->() ){
        let url: URL = URL(string: "\(generalURL)/event/getEvent/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode getEvent: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            do{
                let event = try JSONDecoder().decode(Event.self, from: data)
                DispatchQueue.main.async {
                    completion(event)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getEventsByZone(_ latSx: Double, _ lonSx: Double, _ latDx: Double, _ lonDx: Double, completion: @escaping(_ events: [Event]) ->() ){
        let url: URL = URL(string: "\(generalURL)/event/getByZone/\(latSx)/\(lonSx)/\(latDx)/\(lonDx)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode getEvents: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                let delay = DispatchTimeInterval.seconds(10)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // Riprova la connessione al server
                    let homePresenter = PresenterManager.homePresenter
                    let controller = PresenterManager.homePresenter?.homeViewController
                    homePresenter?.getEventsByZone(controller!)
                }
                return
            }
            do{
                print(data.description)
                let events = try JSONDecoder().decode([Event].self, from: data)
                DispatchQueue.main.async {
                    completion(events)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func saveNewEvent(title: String, image: String, date: String, latitude: Double, longitude: Double, address: String, category: String, description: String, owner: String, maxPartecipant: Int, externalLink: String, completion: @escaping(_ result: String) ->() ) {
        
        let url: URL = URL(string: "\(generalURL)/event/save")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let event: [String:String] = [
            "title": title,
            "latitude": latitude.description,
            "longitude": longitude.description,
            "address": address,
            "date": date,
            "tag": category,
            "description": description,
            "image": image,
            "owner": owner,
            "externalLink": externalLink,
            "max_partecipnt": maxPartecipant.description
        ]
        
        let jsonEvent = try? self.jsonEncoder.encode(event)
        
        request.httpBody = jsonEvent
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta evento \(error.debugDescription)")
                return
            }
            
            if let responseData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Somethings goes wrong")
                }
            }
        }
        task.resume()
    }
    
    func updateEvent(title: String, image: String, date: String, latitude: Double, longitude: Double, address: String, category: String, description: String, owner: String, maxPartecipant: Int, externalLink: String, eventId: Int, completion: @escaping(_ result: String) ->() ){
        
        let url: URL = URL(string: "\(generalURL)/event/update/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let event: [String:String] = [
            "title": title,
            "latitude": latitude.description,
            "longitude": longitude.description,
            "address": address,
            "date": date,
            "tag": category,
            "description": description,
            "image": image,
            //"qrData": qrData,
            "owner": owner,
            "externalLink": externalLink,
            "max_partecipnt": maxPartecipant.description
        ]
        
        let jsonEvent = try? self.jsonEncoder.encode(event)
        
        request.httpBody = jsonEvent
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode: \(httpResponse.statusCode)")
                
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta evento \(error.debugDescription)")
                return
            }
            
            if let responseData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Somethings goes wrong")
                }
            }
        }
        task.resume()
        
    }
    
    func deleteEvent(_ eventId: Int, completion: @escaping(_ result: String) -> ()) {
        let url: URL = URL(string: "\(generalURL)/event/delete/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode getEvents: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            print(data.description)
            if let responseData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Somethings goes wrong")
                }
            }
        }
        task.resume()
    }
    
    func addPartecipation(_ eventId: Int, completion: @escaping(_ result: String) -> ()) {
        guard let userId = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'UserID")
            return
        }
        let url: URL = URL(string: "\(generalURL)/partecipation/add/\(eventId)/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode addPartecipation: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            print(data.description)
            if let responseData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Somethings goes wrong")
                }
            }
        }
        task.resume()
    }
    
    func checkPartecipate(_ eventId: Int, _ userId: String, completion: @escaping(_ result: Bool) -> ()) {
        let url: URL = URL(string: "\(generalURL)/partecipation/check/\(eventId)/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode checkPartecipate: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            do{
                let responseData = try JSONDecoder().decode(Bool.self, from: data)
                DispatchQueue.main.async {
                    completion(responseData)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func removePartecipation(_ eventId: Int, completion: @escaping(_ result: String) -> ()) {
        guard let userId = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'UserID")
            return
        }
        let url: URL = URL(string: "\(generalURL)/partecipation/remove/\(eventId)/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode removePartecipation: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            print(data.description)
            if let responseData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Somethings goes wrong")
                }
            }
        }
        task.resume()
    }
    
    func addToFavourites(_ eventId: Int, completion: @escaping(_ result: String) -> ()) {
        guard let userId = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'UserID")
            return
        }
        print("addFavourite-----------------------")
        let url: URL = URL(string: "\(generalURL)/favourite/add/\(eventId)/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode addToFavourites: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            print(data.description)
            if let responseData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Somethings goes wrong")
                }
            }
        }
        task.resume()
    }
    
    func checkFavourites(_ eventId: Int, _ userId: String, completion: @escaping(_ result: Bool) -> ()) {
        let url: URL = URL(string: "\(generalURL)/favourite/check/\(eventId)/\(userId)")!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode checkFavourites: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            do{
                let responseData = try JSONDecoder().decode(Bool.self, from: data)
                DispatchQueue.main.async {
                    completion(responseData)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func removeFromFavourite(_ eventId: Int, completion: @escaping(_ result: String) -> ()) {
        guard let userId = UserDefaultsManager.shared.value else {
            print("Impossibile recuperare l'UserID")
            return
        }
        let url: URL = URL(string: "\(generalURL)/favourite/remove/\(eventId)/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode removeFromFavourites: \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            
            print(data.description)
            if let responseData = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseData)
                }
            } else {
                DispatchQueue.main.async {
                    completion("Somethings goes wrong")
                }
            }
        }
        task.resume()
    }
    
    func getEventList(_ requestedList: String, _ userId: String, completion: @escaping(_ events: [Event]) -> ()){
        var url: URL?
        switch requestedList{
        case "created":
            url = URL(string: "\(generalURL)/event/created/\(userId)")!
        case "favourites":
            url = URL(string: "\(generalURL)/favourite/get/\(userId)")!
        case "partecipated":
            url = URL(string: "\(generalURL)/partecipation/get/\(userId)")!
        default:
            return
        }
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpStatusCode getList \(requestedList): \(httpResponse.statusCode)")
            }
            guard let data = data, error == nil else {
                print("Errore nella richiesta \(error.debugDescription)")
                return
            }
            do{
                let events = try JSONDecoder().decode([Event].self, from: data)
                DispatchQueue.main.async {
                    completion(events)
                }
            }catch {
                print(error)
            }
        }
        task.resume()
    }
}

    
    

