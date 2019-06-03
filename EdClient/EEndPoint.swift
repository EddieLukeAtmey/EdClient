//
//  EEndPoint.swift
//  EdClient
//
//  Created by Eddie Luke Atmey on 06/04/19.
//  Copyright © 2019 Eddie. All rights reserved.
//

import Foundation

typealias Path = String
typealias Parameters = [String: Any]

enum Method: String {
    case get, post, put, patch, delete

    // You can change default here, but be careful, as you should only change it once
    static var `default`: Method { return .get }
}

final class EEndPoint<Response> {
    let method: Method
    let path: Path
    let parameters: Parameters?
    let decode: (Data) throws -> Response

    init(method: Method = .default,
         path: Path, parameters: Parameters? = nil, decode: @escaping (Data) throws -> Response) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.decode = decode
    }
}

// Quick parse with decodable
extension EEndPoint where Response: Decodable {
    convenience init(method: Method = .default, path: Path, parameters: Parameters? = nil) {
        self.init(method: method, path: path, parameters: parameters) {

            let decoder = JSONDecoder()

            // FIXME: Custom Decoder here
            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            decoder.dateDecodingStrategy = .formatted...
//            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+", negativeInfinity: "-", nan: "0")

            return try decoder.decode(Response.self, from: $0)
        }
    }
}

// No need to parse anything
extension EEndPoint where Response == Void {
    convenience init(method: Method = .default,
                     path: Path,
                     parameters: Parameters? = nil) {
        self.init(method: method, path: path, parameters: parameters) { _ in () }
    }
}

// Write other custom parser here (XMLParser, JSONParser, ObjectMapper...)
