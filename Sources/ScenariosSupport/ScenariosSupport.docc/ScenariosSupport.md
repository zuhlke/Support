# ``ScenariosSupport``

A library to facilitate creation of internal apps and other multi-entry tools.

## Overview

Often when creating an app it’s necessary to also create an “internal” version of the app, for example to provide
access to non-production environments, additional logging, and other testing and debugging facilities.

Whilst this library is primarily targetting creation of such apps, many of the concerns mentioned above (such as 
multiple entry points and varying log levels) also applies to command line tools. As such, we may explicitly address
some of these use cases in this library. 

## Topics

### Scenario Generation

- <doc:Runtime-Class-Discovery>
