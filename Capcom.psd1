@{
# Script module or binary module file associated with this manifest.
ModuleToProcess = 'Capcom.psm1'

# Version number of this module.
ModuleVersion = '0.0.0.1'

# ID used to uniquely identify this module
GUID = 'd34db33f-f3e7-417d-8735-e624dd62e7c8'

# Author of this module
Author = 'Ruben Boonen'

# Copyright statement for this module
Copyright = 'BSD 3-Clause'

# Description of the functionality provided by this module
Description = 'Rootkit POC based on signed Capcom.sys driver!'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Architecture is x64 only
ProcessorArchitecture = 'AMD64'

# Functions to export from this module
FunctionsToExport = @(
    'Capcom-ElevatePID',
    'Capcom-BypassDriverSigning'
)
}