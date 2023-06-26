import Foundation
import CoreLocation

class LocationDataManager : NSObject, CLLocationManagerDelegate {
   var locationManager = CLLocationManager()

   override init() {
      super.init()
      locationManager.delegate = self
   }

   // Location-related properties and delegate methods.
    
}
