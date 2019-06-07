//
//  You can delete this file from src code
//  SampleUsage.swift
//  EdClient
//
//  Created by Eddie Luke Atmey on 06/04/19.
//  Copyright © 2019 Eddie. All rights reserved.
//

import Foundation
import Promises

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
func singleRequest() {

    // Promises a single request and error
    EdClient.shared.request(API.Customer.get(id: "123")).then { customer in
        print("\(customer.id) - \(customer.name), - \(customer.email)")
    }.catch({ print($0) })
}

func multipleRequest(_ ids: [String]) {

//    HUD.show()
    all( ids.map({ EdClient.shared.request(API.Customer.get(id: $0)) })
    ).then { $0.first(where: { $0.email == "eddie.marvin116@gmail.com" })
    }.then { print("Hello \($0?.name ?? "anon")") }
    .catch { print($0) }
    .always { /* HUD.hide() */ }
}

func chainRequest() {
    EdClient.shared.request(API.Customer.get(id: "11")).then {
        var y = $0; y.name = "Eddie"
        try await (EdClient.shared.request(API.Customer.update(y)))
    }.then {
        guard $0.name == "Eddie" else { throw "Update failed" }
        print("Hi \($0.email)")

    }.catch { print($0) }
}

extension String: Error {}
