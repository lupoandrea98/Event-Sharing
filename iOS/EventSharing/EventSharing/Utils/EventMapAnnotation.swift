import Foundation
import MapKit

class EventMapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var eventId: Int
    
    init(coordinate: CLLocationCoordinate2D, title: String, date: String, eventId: Int) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = date
        self.eventId = eventId
    }
    
}
