import UIKit
import MapKit
import CoreLocation

class CountryDetailScreen: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCountryInfo: UILabel!
    
    var country:CountryModel?
    let geocoder = CLGeocoder()
    private let dbHelper = CoreDBHelper.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.geocoder.geocodeAddressString(country!.capital) { [self]
            (resultsList, error) in
            if error != nil {
                print("An error occured during forward geocoding.")
                let centerOfMapCoordinate = CLLocationCoordinate2D(latitude: country!.lat, longitude: country!.lng)
                let zoomLevel = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                let visibleRegion = MKCoordinateRegion(center: centerOfMapCoordinate , span: zoomLevel)
                self.mapView.setRegion(visibleRegion, animated: true)
                
                let mapMarker = MKPointAnnotation()
                mapMarker.coordinate = centerOfMapCoordinate
                mapMarker.title = "The Capital of \(self.country!.name) is \(self.country!.capital)"
                self.mapView.addAnnotation(mapMarker)
            }
            else {
                let locationResult:CLPlacemark = resultsList!.first!
                let lat = locationResult.location?.coordinate.latitude
                let lng = locationResult.location?.coordinate.longitude
                if let lat = lat, let lng = lng {
                    let centerOfMapCoordinate = CLLocationCoordinate2D(latitude:lat, longitude: lng)
                    let zoomLevel = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
                    let visibleRegion = MKCoordinateRegion(center: centerOfMapCoordinate , span: zoomLevel)
                    self.mapView.setRegion(visibleRegion, animated: true)
                    
                    let mapMarker = MKPointAnnotation()
                    mapMarker.coordinate = centerOfMapCoordinate
                    mapMarker.title = "The Capital of \(self.country!.name) is \(self.country!.capital)"
                    self.mapView.addAnnotation(mapMarker)
                }
                else {
                    print("The coordinates are null!")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblCountryInfo.text = "Country Name: \(country!.name)\nCountry Code: \(country!.code)\nCapital: \(country!.capital)\nPopulation: \(country!.population)"
    }
    
    @IBAction func addtoFavoriteButtonPressed(_ sender: Any) {
        for c in dbHelper.getAllCountries()! {
            if c.countryName == country!.name {
                let alert = UIAlertController(title: "Error", message: "This country is already favorited!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
                return
            }
        }
        dbHelper.addFavoriteCountry(name: country!.name)
        let alert = UIAlertController(title: "Success", message: "\(country!.name) got added to favorite Countries!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
