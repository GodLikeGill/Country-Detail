import Foundation

struct Country : Codable {
    
    let name:String
    let alpha3Code:String
    let population:Int
    let capital:String
    let latlng:[Double]
    
    enum countryKeys: String, CodingKey {
        
        case name
        case alpha3Code
        case population
        case capital
        case latlng
    }
    
    init(from decoder: Decoder) throws {
        let countryContainer = try decoder.container(keyedBy: countryKeys.self)
        self.name = try countryContainer.decodeIfPresent(String.self, forKey: .name) ?? "N/A"
        self.alpha3Code = try countryContainer.decodeIfPresent(String.self, forKey: .alpha3Code) ?? "N/A"
        self.population = try countryContainer.decodeIfPresent(Int.self, forKey: .population) ?? 0
        self.capital = try countryContainer.decodeIfPresent(String.self, forKey: .capital) ?? "N/A"
        self.latlng = try countryContainer.decodeIfPresent(Array.self, forKey: .latlng) ?? [Double]()
    }
}
