import Foundation

class CountryFetcher {
    
    @Published var countryList = [Country]()
    private static var shared:CountryFetcher?
    var apiURL = "https://restcountries.com/v2/all"
    
    static func getInstance() -> CountryFetcher {
        if shared == nil {
            shared = CountryFetcher()
        }
        return shared!
    }
    
    func fetchDataFromAPI() {
        guard let api = URL(string: apiURL) else {
            print("Unable to obtain URL from String")
            return
        }
        
        URLSession.shared.dataTask(with: api) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error)")
                return
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        DispatchQueue.global().async {
                            do {
                                if data != nil {
                                    if let jsonData = data {
                                        let decoder = JSONDecoder()
                                        let decodedCountryList = try decoder.decode([Country].self, from: jsonData)
                                        DispatchQueue.main.async {
                                            self.countryList = decodedCountryList
                                            print("Data received from the API is:\n\(self.countryList)")
                                        }
                                    }
                                }
                            } catch let error {
                                print("Found Error: \(error)")
                            }
                        }
                    } else {
                        print("Unsuccessful respone from network call or API")
                    }
                }
            }
        }.resume()
    }
}
