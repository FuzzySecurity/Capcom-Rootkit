function Bitmap-Write {
	param ($Address, $Value)

	$CallResult = [Capcom]::SetBitmapBits($ManagerBitmap.BitmapHandle, [System.IntPtr]::Size, [System.BitConverter]::GetBytes($Address))
	$CallResult = [Capcom]::SetBitmapBits($WorkerBitmap.BitmapHandle, [System.IntPtr]::Size, [System.BitConverter]::GetBytes($Value))
}