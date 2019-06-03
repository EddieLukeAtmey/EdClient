//
//  EdClient.swift
//  EdClient
//
//  Created by Eddie Luke Atmey on 06/04/19.
//  Copyright © 2019 Eddie. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

// This is for RxSwift
protocol ClientProtocol {

    /// kean.github:
    /// Each request is wrapped in a Single observable provided by RxSwift.
    /// I’m going to show why this is useful later in a Usage section
    func request<Response>(_ endpoint: EEndPoint<Response>) -> Single<Response>
}

final class EdClient: ClientProtocol {

    // MARK: - Definiations
    private let manager: SessionManager
    private var baseURL: URL
    private var queue: DispatchQueue

    // FIXME: custom base url
    static let shared = EdClient(baseURL: URL(string: "http://kean.github.io/post/api-client")!, queue: DispatchQueue(label: "EdClient"))
    var accessToken: String? {
        didSet {
            guard let accessToken = accessToken else { EdClient.sharedWithToken = nil; return } // clear shared
            EdClient.sharedWithToken = EdClient(accessToken: accessToken, baseURL: baseURL, queue: queue)
        }
    }
    static private(set) var sharedWithToken: EdClient?
    // Add more shared client if you want (external call...)

    convenience init(baseURL: URL, queue: DispatchQueue = .main) {
        self.init(accessToken: nil, baseURL: baseURL, queue: queue)
    }

    private init(accessToken: String?, baseURL: URL, queue: DispatchQueue) {

        self.accessToken = accessToken
        self.baseURL = baseURL
        self.queue = queue

        // FIXME: Custom initializer and configurations
        let configuration = URLSessionConfiguration.default
        guard let accessToken = accessToken else {
            manager = SessionManager(configuration: configuration)
            return
        }

        var defaultHeaders = SessionManager.defaultHTTPHeaders
        defaultHeaders["Authorization"] = "Bearer \(accessToken)"
        configuration.httpAdditionalHeaders = defaultHeaders

        manager = SessionManager(configuration: configuration)
        manager.retrier = OAuth2Retrier()
    }

    // RxSwift
    func request<Response>(_ endpoint: EEndPoint<Response>) -> Single<Response> {

        // RxSwift
        return Single<Response>.create { observer in

            // Alamofire
            let request = self.manager.request(
                self.fullURL(endpoint.path),
                method: HTTPMethod(rawValue: endpoint.method.rawValue)!,
                parameters: endpoint.parameters
            )

            request
                .validate() // Alamofire
                .responseData(queue: self.queue) { response in
                    let result = response.result.flatMap(endpoint.decode)
                    switch result {
                    case let .success(val): observer(.success(val))
                    case let .failure(err): observer(.error(err))
                    }
            }

            // RxSwift
            return Disposables.create {
                request.cancel()
            }
        }

    }

    private func fullURL(_ path: Path) -> URL { return baseURL.appendingPathComponent(path) }
}

final class OAuth2Retrier: RequestRetrier {
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if (error as? AFError)?.responseCode == 401 {
            // TODO: implement your Auth2 refresh flow
            // See https://github.com/Alamofire/Alamofire#adapting-and-retrying-requests
        }

        completion(false, 0)
    }
}
