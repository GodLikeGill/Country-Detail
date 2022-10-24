import Foundation
import CoreData
import UIKit

class CoreDBHelper {
    
    private static var shared:CoreDBHelper?
    private let moc:NSManagedObjectContext
    
    private let ENTITY_NAME = "FavoriteCountry"
    
    static func getInstance() -> CoreDBHelper {
        if (shared == nil){
            shared = CoreDBHelper(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        }
        return shared!
    }
    
    private init(context : NSManagedObjectContext){
        self.moc = context
    }
    
    func getAllCountries() -> [FavoriteCountry]? {
        let fetchRequest = NSFetchRequest<FavoriteCountry>(entityName: ENTITY_NAME)
        do{
            let result = try self.moc.fetch(fetchRequest)
            return result as [FavoriteCountry]
        }catch let error as NSError{
            print("Could not fetch the data. \(error)")
        }
        return nil
    }
    
    func searchFavoriteCountry(name : String) -> FavoriteCountry? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_NAME)
        let predicateID = NSPredicate(format: "countryName == %@", name as CVarArg)
        fetchRequest.predicate = predicateID
        do{
            let result = try self.moc.fetch(fetchRequest)
            if result.count > 0 {
                return result.first as? FavoriteCountry
            }
        }catch let error as NSError{
            print("Unable to search for Favorite Country. \(error)")
        }
        return nil
    }
    
    func addFavoriteCountry(name: String) {
        do{
            let countryToBeInserted = NSEntityDescription.insertNewObject(forEntityName: ENTITY_NAME, into: self.moc) as! FavoriteCountry
            
            countryToBeInserted.countryName = name
            
            if self.moc.hasChanges{
                try self.moc.save()
            }
        }catch let error as NSError{
            print("Could not save the data. \(error)")
        }
    }
    
    func deleteFavoriteCountry(name : String){
        let searchResult = self.searchFavoriteCountry(name: name)
        if (searchResult != nil){
            do{
                self.moc.delete(searchResult!)
                try self.moc.save()
            }catch let error as NSError{
                print("Could not delete the Country from Favorite Country. \(error)")
            }
        }else{
            print("No matching record found.")
        }
    }
}
