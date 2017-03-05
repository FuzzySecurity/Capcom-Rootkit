function Load-CapcomDriver {
	param([String]$Path)

	# Driver loading not supported on Win7
	if ($OSMajMin -le 6.1) {
		Write-Output "[!] Automatic driver loading not supported on this OS!`n"
		$Global:DriverNotLoaded = $true
		Return
	}

	# Check if the user is running as Admin
	$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
	if (!$IsAdmin) {
		Write-Output "[!] Administrator privilege is required to create a driver service!`n"
		$Global:DriverNotLoaded = $true
		Return
	}

	if (Get-Service "CapcomRK" -ErrorAction SilentlyContinue) {
		if ((Get-Service "CapcomRK").Status -eq "Stopped") {
			Start-Service -Name CapcomRK |Out-Null
		}
	} else {
		# Uses SC because New-Service doesn't support "type= kernel" (..?)
		IEX $($env:SystemRoot + "\System32\sc.exe create CapcomRK binpath= $Path type= kernel start= demand") |Out-Null
		Start-Service -Name CapcomRK |Out-Null
	}
	
	# Check service status
	$ServiceStatus = (Get-Service "CapcomRK").Status
	if ($ServiceStatus -eq "Running") {
		Write-Output "[+] Capcom service started: CapcomRK"
		Get-Service "CapcomRK" |fl
	} else {
		Write-Output "[!] Something went wrong while creating the Capcom service!`n"
		$Global:DriverNotLoaded = $true
		Return
	}
}