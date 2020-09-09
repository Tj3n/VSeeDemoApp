//
//  ViewModel.swift
//  VSeeDemo
//
//  Created by Vũ Tiến on 9/8/20.
//  Copyright © 2020 Vũ Tiến. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MasterViewModel<T: NSFetchedResultsControllerDelegate> {
    
    private var controller: T
    var articles = [Article]()
    
    init(controller: T) {
        self.controller = controller
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Article> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managerContext = appDelegate.persistentContainer.viewContext

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managerContext, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = controller

        return fetchedResultsController
    }()
    
    func load(){
        do {
            try self.fetchedResultsController.performFetch()
            self.articles = fetchedResultsController.fetchedObjects ?? []
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
}
