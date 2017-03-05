# Compatibility for PS v2 / PS v3+
if(!$PSScriptRoot) {
	$Global:PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

# OS version
$OSVersion = [Version](Get-WmiObject Win32_OperatingSystem).Version
[double]$Global:OSMajMin = "$($OSVersion.Major).$($OSVersion.Minor)"

# Import all modules
Get-ChildItem -Recurse $PSScriptRoot | % { if ($_.FullName -Like "*.ps1") { Import-Module $_.FullName -DisableNameChecking } }