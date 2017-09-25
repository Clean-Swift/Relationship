//
//  CustomerCoreDataStore.swift
//  Relationship
//
//  Created by Raymond Law on 9/16/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

import Foundation
import CoreData

protocol CustomerStoreProtocol
{
  func fetchCustomers(completionHandler: @escaping (() throws -> [ManagedCustomer]) -> Void)
  func fetchCustomer(id: String, completionHandler: @escaping (() throws -> ManagedCustomer?) -> Void)
  func createCustomer(customerToCreate: Customer, completionHandler: @escaping (() throws -> ManagedCustomer?) -> Void)
  func updateCustomer(customerToUpdate: Customer, completionHandler: @escaping (() throws -> ManagedCustomer?) -> Void)
  func deleteCustomer(id: String, completionHandler: @escaping (() throws -> Void) -> Void)
}

class CustomerCoreDataStore: CoreDataStore, CustomerStoreProtocol
{
  // MARK: - Object lifecycle
  
  static let shared = CustomerCoreDataStore()
  private override init() {}
  
  // MARK: - CRUD operations
  
  func fetchCustomers(completionHandler: @escaping (() throws -> [ManagedCustomer]) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCustomer")
      let managedCustomers = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedCustomer]
      DispatchQueue.main.async {
        completionHandler { return managedCustomers }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotFetch("Cannot fetch customers") }
      }
    }
  }
  
  func fetchCustomer(id: String, completionHandler: @escaping (() throws -> ManagedCustomer?) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCustomer")
      fetchRequest.predicate = NSPredicate(format: "id == %@", id)
      let managedCustomers = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedCustomer]
      if let managedCustomer = managedCustomers.first {
        DispatchQueue.main.async {
          completionHandler { return managedCustomer }
        }
      } else {
        DispatchQueue.main.async {
          completionHandler { throw CoreDataStoreError.CannotFetch("Cannot fetch customer with id \(id)") }
        }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotFetch("Cannot fetch customer with id \(id)") }
      }
    }
  }
  
  func createCustomer(customerToCreate: Customer, completionHandler: @escaping (() throws -> ManagedCustomer?) -> Void)
  {
    let managedCustomer = NSEntityDescription.insertNewObject(forEntityName: "ManagedCustomer", into: CoreDataStore.mainManagedObjectContext) as! ManagedCustomer
    managedCustomer.id = customerToCreate.id
    managedCustomer.name = customerToCreate.name
    let managedLicenses = customerToCreate.licenses.map { (license) -> ManagedLicense in
      let managedLicense = NSEntityDescription.insertNewObject(forEntityName: "ManagedLicense", into: CoreDataStore.mainManagedObjectContext) as! ManagedLicense
      managedLicense.id = license.id
      managedLicense.serial = license.serial
      managedLicense.managedCustomer = managedCustomer
      return managedLicense
    }
    managedCustomer.managedLicenses = NSSet(array: managedLicenses)
    do {
      try CoreDataStore.mainManagedObjectContext.save()
      DispatchQueue.main.async {
        completionHandler { return managedCustomer }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotCreate("Cannot create customer with id \(String(describing: customerToCreate.id))") }
      }
    }
  }
  
  func updateCustomer(customerToUpdate: Customer, completionHandler: @escaping (() throws -> ManagedCustomer?) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCustomer")
      fetchRequest.predicate = NSPredicate(format: "id == %@", customerToUpdate.id)
      let managedCustomers = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedCustomer]
      if let managedCustomer = managedCustomers.first {
        managedCustomer.id = customerToUpdate.id
        managedCustomer.name = customerToUpdate.name
        do {
          try CoreDataStore.mainManagedObjectContext.save()
          DispatchQueue.main.async {
            completionHandler { return managedCustomer }
          }
        } catch {
          DispatchQueue.main.async {
            completionHandler { throw CoreDataStoreError.CannotUpdate("Cannot update customer with id \(String(describing: customerToUpdate.id))") }
          }
        }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotUpdate("Cannot fetch customer with id \(String(describing: customerToUpdate.id)) to update") }
      }
    }
  }
  
  func deleteCustomer(id: String, completionHandler: @escaping (() throws -> Void) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCustomer")
      fetchRequest.predicate = NSPredicate(format: "id == %@", id)
      let managedCustomers = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedCustomer]
      if let managedCustomer = managedCustomers.first {
        CoreDataStore.mainManagedObjectContext.delete(managedCustomer)
        try CoreDataStore.mainManagedObjectContext.save()
        DispatchQueue.main.async {
          completionHandler {}
        }
      } else {
        DispatchQueue.main.async {
          completionHandler { throw CoreDataStoreError.CannotDelete("Cannot fetch customer with id \(id) to delete") }
        }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotDelete("Cannot fetch customer with id \(id) to delete") }
      }
    }
  }
  
  // MARK: - Debugging
  
  func printManagedCustomers(message: String, managedCustomers: [ManagedCustomer])
  {
    debugPrint(#function, message)
    managedCustomers.forEach({ (managedCustomer) in
      debugPrint(managedCustomer)
    })
  }
}
