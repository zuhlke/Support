import Foundation

public struct HTTPRequest: Equatable {
    
    public init(
        method: HTTPMethod,
        path: String,
        body: Body?,
        fragment _: String? = nil,
        queryParameters _: [String: String] = [:],
        headers _: [String: String] = [:]
    ) {
        guard path.isEmpty || path.starts(with: "/") else {
            Thread.fatalError("`path` must start with `/` if it’s not empty.")
        }
        
        let hasBody = (body != nil)
        if hasBody, method.mustNotHaveBody {
            Thread.fatalError("Method \(method) does not support body.")
        }
        
        if !hasBody, method.mustHaveBody {
            Thread.fatalError("Method \(method) requires a body.")
        }
    }
    
}

extension HTTPRequest {
    
    public static func get(
        _ path: String,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: path,
            body: nil,
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
    public static func post(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
    public static func put(
        _ path: String,
        body: Body,
        fragment: String? = nil,
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: path,
            body: body,
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
}
