# Logging UI

@Metadata {
    @Available(iOS, introduced: "26.0")
    @Available(macOS, introduced: "15.0")
}

Ready made user interface to retrieve and visualise logs.

## Overview

`LoggingUI` provides a premade user interface that uses `LogRetriever` from `Support` to show any logs stored by using `LogMonitor` from `Support`.

``AppGroupLogView`` is a full screen view, already with a navstack that provides a hierarchical navigation interface for browsing logs across multiple applications and their extensions (main app, widgets, etc.).

``LogImportView`` is a macOS-only view that provides a drag-and-drop interface for importing and viewing log files.
