//
//  You can delete this file from src code
//  SampleUsage.swift
//  EdClient
//
//  Created by Eddie Luke Atmey on 06/04/19.
//  Copyright © 2019 Eddie. All rights reserved.
//

import Foundation

// Sample APIS description
struct API {}
extension API {

    enum Customer {
        private static let path = "customer"

        // API need end point of course!
        static func get(id: String) -> EEndPoint<CustomerModel> { return EEndPoint(path: path) }

        static func update(_ updatingCustomer: CustomerModel) -> EEndPoint<CustomerModel> {
//            let param = update
            let data = try! JSONEncoder().encode(updatingCustomer)
            let param = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Parameters
            return EEndPoint(path: path, parameters: param)
        }

    }
}

struct CustomerModel: Codable {
    var id: String
    var name: String
    var email: String
}

// Sample usage
func test() {

    // TODO: Continue with Rx
    EdClient.shared.request(API.Customer.get(id: "123"))

}
