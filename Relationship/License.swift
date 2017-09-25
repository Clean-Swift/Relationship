//
//  License.swift
//  Relationship
//
//  Created by Raymond Law on 9/19/17.
//  Copyright © 2017 Clean Swift LLC. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Entity model

class License: NSObject
{
  // MARK: Attributes
  
  var id: String
  var serial: String
  unowned var customer: Customer
  
  // MARK: Object lifecycle
  
  init(id: String, serial: String, customer: Customer)
  {
    self.id = id
    self.serial = serial
    self.customer = customer
  }
  
  override var debugDescription: String
  {
    return "License<id:\(id) serial:\(serial) customer:\(customer)>"
  }
}

// MARK: - Core Data model

extension ManagedLicense
{
  func toLicense(customer: Customer) -> License
  {
    let license = License(id: id!, serial: serial!, customer: customer)
    return license
  }
}
