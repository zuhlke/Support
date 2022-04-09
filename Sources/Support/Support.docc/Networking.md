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

### Preparing a type-safe API  

- ``HTTPService``
- ``HTTPEndpoint``

### HTTP data types 

- ``HTTPRemote``
- ``HTTPRequest``
- ``HTTPResponse``
- ``HTTPHeaders``
- ``HTTPHeaderFieldName``
- ``HTTPMethod``
- ``URLScheme``

### Supporting types

- ``HTTPCallableEndpoint``

### Deprecated

- ``AsyncHTTPClient``
- ``HTTPRequestError``
- ``NetworkRequestError``
