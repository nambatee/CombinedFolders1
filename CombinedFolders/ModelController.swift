import Foundation
import CoreData

class ModelController: NSObject {

    override init() {
        super.init()
        clearAll()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CombinedFolders")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func createNewFolders(names: [String]) {
        for name in names {
            let folder = NSEntityDescription.insertNewObject(forEntityName: "Folder", into: persistentContainer.viewContext) as! Folder
            folder.name = name
        }
        saveContext()
    }

    func createNewFolder(named name: String) {
        let folder = NSEntityDescription.insertNewObject(forEntityName: "Folder", into: persistentContainer.viewContext) as! Folder
        folder.name = name
        saveContext()
    }

    func clearAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Folder")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? persistentContainer.viewContext.execute(batchDeleteRequest)
    }
}
