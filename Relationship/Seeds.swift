//
//  Seeds.swift
//  Relationship
//
//  Created by Raymond Law on 9/16/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

import Foundation
import CoreData

struct Seeds
{
  static let customerCoreDataStore = CustomerCoreDataStore.shared
  
  private static func deleteAllCustomers()
  {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedCustomer")
    let managedCustomers = try! CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedCustomer]
    managedCustomers.forEach { (managedCustomer) in
      CoreDataStore.mainManagedObjectContext.delete(managedCustomer)
    }
    try! CoreDataStore.mainManagedObjectContext.save()
  }
  
  private static func deleteAllLicenses()
  {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedLicense")
    let managedLicenses = try! CoreDataStore.mainManagedObjectContext.fetch(fetchRequest) as! [ManagedLicense]
    managedLicenses.forEach { (managedLicense) in
      CoreDataStore.mainManagedObjectContext.delete(managedLicense)
    }
    try! CoreDataStore.mainManagedObjectContext.save()
  }
  
  static func populate()
  {
    deleteAllCustomers()
    deleteAllLicenses()
    
    let amy = Customer(id: "amy", name: "Amy", licenses: [])
    let bob = Customer(id: "bob", name: "Bob", licenses: [])
    let cas = Customer(id: "cas", name: "Cas", licenses: [])
    
    let a1 = License(id: "a1", serial: "a1", customer: amy)
    let b1 = License(id: "b1", serial: "b1", customer: bob)
    let b2 = License(id: "b2", serial: "b2", customer: bob)
    let c1 = License(id: "c1", serial: "c1", customer: cas)
    let c2 = License(id: "c2", serial: "c2", customer: cas)
    let c3 = License(id: "c3", serial: "c3", customer: cas)
    
    amy.licenses = [a1]
    bob.licenses = [b1, b2]
    cas.licenses = [c1, c2, c3]
    
    let customers = [amy, bob, cas]
    
    customers.forEach { (customer) in
      
      var managedLicenses: [ManagedLicense] = []
      customer.licenses.forEach({ (license) in
        let managedLicense = NSEntityDescription.insertNewObject(forEntityName: "ManagedLicense", into: CoreDataStore.mainManagedObjectContext) as! ManagedLicense
        managedLicense.id = license.id
        managedLicense.serial = license.serial
        managedLicenses.append(managedLicense)
      })
      
      let managedCustomer = NSEntityDescription.insertNewObject(forEntityName: "ManagedCustomer", into: CoreDataStore.mainManagedObjectContext) as! ManagedCustomer
      managedCustomer.id = customer.id
      managedCustomer.name = customer.name
      managedCustomer.addToManagedLicenses(NSSet(array: managedLicenses))
      
      try! CoreDataStore.mainManagedObjectContext.save()
    }
  }
}
