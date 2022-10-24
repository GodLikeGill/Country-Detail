import UIKit
import Combine

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let countryFetcher = CountryFetcher.getInstance()
    private let dbHelper = CoreDBHelper.getInstance()
    private var cancellables: Set<AnyCancellable> = []
    private var countryList = [Country]()
    private var favoriteCountryList = [Country]()
    private var isShowAll:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Show Favorites", style: .done, target: self, action: #selector(showFavoriteCountries))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show All", style: .done, target: self, action: #selector(showAllCountries))
        
        self.countryFetcher.fetchDataFromAPI()
        receiveChanges()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showAllCountries()
        tableViewUpdate()
    }
    
    private func tableViewUpdate(){
        favoriteCountryList = [Country]()
        for country in countryList {
            if dbHelper.getAllCountries()!.contains(dbHelper.searchFavoriteCountry(name: country.name) ?? FavoriteCountry()) {
                favoriteCountryList.append(country)
            }
        }
        tableView.reloadData()
    }
    
    @objc func showAllCountries() {
        isShowAll = true
        tableViewUpdate()
        lblTitle.text = "All Countries"
    }
    
    @objc func showFavoriteCountries() {
        isShowAll = false
        tableViewUpdate()
        lblTitle.text = "Favorite Countries"
    }
    
    private func receiveChanges() {
        self.countryFetcher.$countryList
            .receive(on: RunLoop.main)
            .sink{ (countries) in
                self.countryList.removeAll()
                self.countryList.append(contentsOf: countries)
                self.tableViewUpdate()
            }
            .store(in: &cancellables)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowAll {
            return countryList.count
        } else {
            return favoriteCountryList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        if (isShowAll) {
            cell.textLabel?.text = "Country: \(countryList[indexPath.row].name)"
            cell.detailTextLabel?.text = "Population: \(countryList[indexPath.row].population)"
            if (dbHelper.getAllCountries()!.contains(dbHelper.searchFavoriteCountry(name: countryList[indexPath.row].name) ?? FavoriteCountry())) {
                cell.textLabel?.backgroundColor = .systemYellow
                cell.detailTextLabel?.backgroundColor = .systemYellow
            } else {
                cell.textLabel?.backgroundColor = .white
                cell.detailTextLabel?.backgroundColor = .white
            }
        } else {
            cell.textLabel?.text = "Country: \(favoriteCountryList[indexPath.row].name)"
            cell.detailTextLabel?.text = "Population: \(favoriteCountryList[indexPath.row].population)"
            cell.textLabel?.backgroundColor = .systemYellow
            cell.detailTextLabel?.backgroundColor = .systemYellow
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextScreen = storyboard?.instantiateViewController(identifier: "CountryDetailScreen") as? CountryDetailScreen else {
            print("Cannot find next screen")
            return
        }
        var country = countryList[indexPath.row]
        if (!isShowAll) {
            country = favoriteCountryList[indexPath.row]
        }
        nextScreen.country = CountryModel(name: country.name, code: country.alpha3Code, capital: country.capital, population: country.population, lat: country.latlng[0], lng: country.latlng[1])
        self.navigationController?.pushViewController(nextScreen, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (isShowAll){
                dbHelper.deleteFavoriteCountry(name: countryList[indexPath.row].name)
            } else {
                dbHelper.deleteFavoriteCountry(name: favoriteCountryList[indexPath.row].name)
            }
            tableViewUpdate()
        }
    }
}
