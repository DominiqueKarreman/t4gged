import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var isInitialZoom = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else { return }
        
        if isInitialZoom {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            isInitialZoom = false
        }
    }

    @IBAction func zoomToUserLocation(_ sender: UIButton) {
        guard let userLocation = locationManager.location else { return }
        let zoomLevel: CLLocationDistance = 500 // Adjust this value for desired zoom level (meters)
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: zoomLevel, longitudinalMeters: zoomLevel)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomIn(_ sender: UIButton) {
        zoom(byFactor: 0.5)
    }

    @IBAction func zoomOut(_ sender: UIButton) {
        zoom(byFactor: 2.0)
    }

    func zoom(byFactor factor: Double) {
        var region: MKCoordinateRegion = mapView.region
        var span: MKCoordinateSpan = mapView.region.span
        span.latitudeDelta *= factor
        span.longitudeDelta *= factor
        region.span = span
        mapView.setRegion(region, animated: true)
    }

}