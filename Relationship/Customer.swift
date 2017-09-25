//
//  Customer.swift
//  Relationship
//
//  Created by Raymond Law on 9/19/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Entity model

class Customer: NSObject
{
  // MARK: Attributes
  
  var id: String
  var name: String
  var licenses: [License]
  
  // MARK: Object lifecycle
  
  init(id: String, name: String, licenses: [License])
  {
    self.id = id
    self.name = name
    self.licenses = licenses
  }
  
  override var debugDescription: String
  {
    return "Customer<id:\(id), name:\(name), licenses:\(licenses)>"
  }
}

// MARK: - Core Data model

extension ManagedCustomer
{
  func toCustomer() -> Customer
  {
    let customer = Customer(id: id!, name: name!, licenses: [])
    let licenses = (managedLicenses?.allObjects as! [ManagedLicense]).map { License(id: $0.id!, serial: $0.serial!, customer: customer) }
    customer.licenses = licenses
    return customer
  }
}
