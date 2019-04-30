import UIKit
import CoreData

class TableViewController: UITableViewController {
    private let reususeIdentifier = "UITableViewCell"
    private let modelController = ModelController()

    private lazy var fetchedResultsController: NSFetchedResultsController<Folder> = {
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Folder.name, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: modelController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let folderNames = ["Folder 1", "Folder 2", "Folder 3"]
        modelController.createNewFolders(names: folderNames)
        try? fetchedResultsController.performFetch()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reususeIdentifier)
    }

    @IBAction private func addNewFolder() {
        let alertController = UIAlertController(title: "Add new folder", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Folder name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let name = alertController.textFields?.first?.text else {
                return
            }
            self.modelController.createNewFolder(named: name)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
}

extension TableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reususeIdentifier, for: indexPath)
        switch indexPath.section {
        case 0:
            guard let folders = fetchedResultsController.fetchedObjects else {
                return cell
            }
            configure(cell: cell, with: folders)
        default:
            let adjustedIndexPath = IndexPath(row: indexPath.row, section: 0)
            let folder = fetchedResultsController.object(at: adjustedIndexPath)
            configure(cell: cell, with: folder)
        }
        return cell
    }

    private func configure(cell: UITableViewCell, with folders: [Folder]) {
        cell.textLabel?.text = folders.compactMap { $0.name }.joined(separator: ", ")
    }

    private func configure(cell: UITableViewCell, with folder: Folder) {
        cell.textLabel?.text = folder.name
    }
}

extension TableViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert where newIndexPath?.section == 0:
            guard let newIndexPath = newIndexPath else {
                return
            }
            let adjustedIndexPath = IndexPath(row: newIndexPath.row, section: 1)
            tableView.insertRows(at: [adjustedIndexPath], with: .fade)
            if let firstIndexPath = tableView.indexPathsForVisibleRows?.first {
                tableView.reloadRows(at: [firstIndexPath], with: .fade)
            }
        default:
            break
        }
    }
}

