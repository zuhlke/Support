# Creating Structured Temporary Directories 

## Overview

``TestingSupport`` defines the following convenience methods to extend existing type. Since extension symbols are
currently not exported as part of documentation, we briefly describe these methods below.

### Using temporary directories

`FileManager.withTemporaryDirectory` creates a temporary directory that only exists during the time that we run the
closure passed into it:

```swift
try FileManager().withTemporaryDirectory { url in 
    // use the temporary directory at `url`.
}
```

This temporary directory is deleted before the method returns.

There are sync and async variants of this method.
