# Networking

Decouple networking app logic from transport concerns.

## Overview

Use ``HTTPService`` to provide a consistent API for accessing HTTP endpoints for a given service. 

## Topics

### Setting up an HTTP networking stack 

- ``HTTPClient``
- ``URLRequestProviding``
- ``URLSessionProtocol``
- ``URLSessionHTTPClient``
- ``HTTPRequestPerformingError``

### Type-safe HTTP networking  

- ``HTTPService``
- ``HTTPEndpoint``
- ``HTTPEndpointCallError``

### HTTP data types 

- ``HTTPRemote``
- ``HTTPRequest``
- ``HTTPResponse``
- ``HTTPMethod``
- ``URLScheme``

### Supporting types

- ``HTTPCallableEndpoint``
