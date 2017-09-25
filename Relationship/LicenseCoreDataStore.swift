//
//  LicenseCoreDataStore.swift
//  Relationship
//
//  Created by Raymond Law on 9/16/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

import Foundation
import CoreData

protocol LicenseStoreProtocol
{
  func fetchLicenses(for customer: Customer, completionHandler: @escaping (() throws -> [ManagedLicense]) -> Void)
  func fetchLicense(id: String, completionHandler: @escaping (() throws -> ManagedLicense?) -> Void)
  func createLicense(licenseToCreate: License, for customer: Customer, completionHandler: @escaping (() throws -> ManagedLicense?) -> Void)
  func updateLicense(licenseToUpdate: License, completionHandler: @escaping (() throws -> ManagedLicense?) -> Void)
  func deleteLicense(id: String, completionHandler: @escaping (() throws -> Void) -> Void)
}

class LicenseCoreDataStore: CoreDataStore, LicenseStoreProtocol
{
  // MARK: - Object lifecycle
  
  static let shared = LicenseCoreDataStore()
  private override init() {}
  
  // MARK: - CRUD operations
  
  func fetchLicenses(for customer: Customer, completionHandler: @escaping (() throws -> [ManagedLicense]) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedLicense")
      fetchRequest.predicate = NSPredicate(format: "ANY managedCustomer.id in %@", [customer.id])
      let managedLicenses = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedLicense]
      DispatchQueue.main.async {
        completionHandler { return managedLicenses }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotFetch("Cannot fetch licenses for customer with id \(customer.id)") }
      }
    }
  }
  
  func fetchLicense(id: String, completionHandler: @escaping (() throws -> ManagedLicense?) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedLicense")
      fetchRequest.predicate = NSPredicate(format: "id == %@", id)
      let managedLicenses = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedLicense]
      if let managedLicense = managedLicenses.first {
        DispatchQueue.main.async {
          completionHandler { return managedLicense }
        }
      } else {
        DispatchQueue.main.async {
          completionHandler { throw CoreDataStoreError.CannotFetch("Cannot fetch license with id \(id)") }
        }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotFetch("Cannot fetch license with id \(id)") }
      }
    }
  }
  
  func createLicense(licenseToCreate: License, for customer: Customer, completionHandler: @escaping (() throws -> ManagedLicense?) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCustomer")
      fetchRequest.predicate = NSPredicate(format: "id == %@", customer.id)
      let managedCustomers = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedCustomer]
      if let managedCustomer = managedCustomers.first {
        let managedLicense = NSEntityDescription.insertNewObject(forEntityName: "ManagedLicense", into: CoreDataStore.mainManagedObjectContext) as! ManagedLicense
        managedLicense.id = licenseToCreate.id
        managedLicense.serial = licenseToCreate.serial
        managedLicense.managedCustomer = managedCustomer
        do {
          try CoreDataStore.mainManagedObjectContext.save()
          DispatchQueue.main.async {
            completionHandler { return managedLicense }
          }
        } catch {
          DispatchQueue.main.async {
            completionHandler { throw CoreDataStoreError.CannotCreate("Cannot create license with id \(String(describing: licenseToCreate.id))") }
          }
        }
      } else {
        DispatchQueue.main.async {
          completionHandler { throw CoreDataStoreError.CannotCreate("Cannot find associated customer with id \(String(describing: customer.id))") }
        }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotCreate("Cannot find associated customer with id \(String(describing: customer.id))") }
      }
    }
  }
  
  func updateLicense(licenseToUpdate: License, completionHandler: @escaping (() throws -> ManagedLicense?) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedLicense")
      fetchRequest.predicate = NSPredicate(format: "id == %@", licenseToUpdate.id)
      let managedLicenses = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedLicense]
      if let managedLicense = managedLicenses.first {
        
        managedLicense.id = licenseToUpdate.id
        managedLicense.serial = licenseToUpdate.serial
        do {
          try CoreDataStore.mainManagedObjectContext.save()
          DispatchQueue.main.async {
            completionHandler { return managedLicense }
          }
        } catch {
          DispatchQueue.main.async {
            completionHandler { throw CoreDataStoreError.CannotUpdate("Cannot update license with id \(String(describing: licenseToUpdate.id))") }
          }
        }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotUpdate("Cannot fetch license with id \(String(describing: licenseToUpdate.id)) to update") }
      }
    }
  }
  
  func deleteLicense(id: String, completionHandler: @escaping (() throws -> Void) -> Void)
  {
    do {
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedLicense")
      fetchRequest.predicate = NSPredicate(format: "id == %@", id)
      let managedLicenses = try CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedLicense]
      if let managedLicense = managedLicenses.first {
        CoreDataStore.mainManagedObjectContext.delete(managedLicense)
        try CoreDataStore.mainManagedObjectContext.save()
        DispatchQueue.main.async {
          completionHandler {}
        }
      } else {
        DispatchQueue.main.async {
          completionHandler { throw CoreDataStoreError.CannotDelete("Cannot fetch license with id \(id) to delete") }
        }
      }
    } catch {
      DispatchQueue.main.async {
        completionHandler { throw CoreDataStoreError.CannotDelete("Cannot fetch license with id \(id) to delete") }
      }
    }
  }
  
  // MARK: - Debugging
  
  func printManagedLicenses(message: String, managedLicenses: [ManagedLicense])
  {
    debugPrint(#function, message)
    managedLicenses.forEach({ (managedLicense) in
      debugPrint(managedLicense)
    })
  }
}
