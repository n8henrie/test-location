import CoreLocation
import Foundation

@main
class Delegate: NSObject, CLLocationManagerDelegate {
  lazy var manager = {
    let clm = CLLocationManager()
    clm.desiredAccuracy = kCLLocationAccuracyReduced
    clm.delegate = self
    clm.startUpdatingLocation()
    return clm
  }()

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    print("Location authorization status: \(manager.authorizationStatus)")
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(locations.first!)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("❌ error \(error._code): \(error.localizedDescription)")
  }

  static func main() {
    let delegate = Delegate()
    delegate.manager.requestWhenInUseAuthorization()
    RunLoop.main.run()
  }
}
