# Networking

Decouple networking app logic from transport concerns.

## Overview

Use ``HTTPService`` to provide a consistent API for accessing HTTP endpoints for a given service. 

## Topics

### Setting up an HTTP networking stack 

- ``HTTPService``
- ``HTTPClient``
- ``HTTPEndpoint``
- ``URLSessionHTTPClient``

### HTTP data types 

- ``HTTPRemote``
- ``HTTPRequest``
- ``HTTPResponse``
- ``HTTPHeaders``
- ``HTTPHeaderFieldName``
- ``HTTPMethod``

### Supporting types

- ``HTTPRequestPerformingError``
- ``HTTPCallableEndpoint``
- ``URLRequestProviding``
- ``URLScheme``
- ``URLSessionProtocol``
- ``HTTPCallableEndpoint``

### Deprecated

- ``AsyncHTTPClient``
- ``HTTPRequestError``
- ``NetworkRequestError``
