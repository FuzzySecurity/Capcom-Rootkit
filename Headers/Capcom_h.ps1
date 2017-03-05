Add-Type -TypeDefinition @"
	using System;
	using System.Diagnostics;
	using System.Runtime.InteropServices;
	using System.Security.Principal;

	[StructLayout(LayoutKind.Sequential, Pack = 1)]
	public struct SYSTEM_MODULE_INFORMATION
	{
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
		public UIntPtr[] Reserved;
		public IntPtr ImageBase;
		public UInt32 ImageSize;
		public UInt32 Flags;
		public UInt16 LoadOrderIndex;
		public UInt16 InitOrderIndex;
		public UInt16 LoadCount;
		public UInt16 ModuleNameOffset;
		[MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
		internal Char[] _ImageName;
		public String ImageName {
			get {
				return new String(_ImageName).Split(new Char[] {'\0'}, 2)[0];
			}
		}
	}

	public static class Capcom
	{
		[DllImport("kernel32.dll", SetLastError = true)]
		public static extern IntPtr VirtualAlloc(
			IntPtr lpAddress,
			uint dwSize,
			UInt32 flAllocationType,
			UInt32 flProtect);
			
		[DllImport("kernel32.dll", SetLastError=true)]
		public static extern bool VirtualFree(
			IntPtr lpAddress,
			uint dwSize,
			uint dwFreeType);
			
		[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		public static extern IntPtr CreateFile(
			String lpFileName,
			UInt32 dwDesiredAccess,
			UInt32 dwShareMode,
			IntPtr lpSecurityAttributes,
			UInt32 dwCreationDisposition,
			UInt32 dwFlagsAndAttributes,
			IntPtr hTemplateFile);
			
		[DllImport("Kernel32.dll", SetLastError = true)]
		public static extern bool DeviceIoControl(
			IntPtr hDevice,
			int IoControlCode,
			byte[] InBuffer,
			int nInBufferSize,
			ref IntPtr OutBuffer,
			int nOutBufferSize,
			ref int pBytesReturned,
			IntPtr Overlapped);
			
		[DllImport("gdi32.dll")]
		public static extern IntPtr CreateBitmap(
			int nWidth,
			int nHeight,
			uint cPlanes,
			uint cBitsPerPel,
			IntPtr lpvBits);
			
		[DllImport("gdi32.dll")]
		public static extern int SetBitmapBits(
			IntPtr hbmp,
			uint cBytes,
			byte[] lpBits);
			
		[DllImport("gdi32.dll")]
		public static extern int GetBitmapBits(
			IntPtr hbmp,
			int cbBuffer,
			IntPtr lpvBits);
			
		[DllImport("ntdll.dll")]
		public static extern int NtQuerySystemInformation(
			int SystemInformationClass,
			IntPtr SystemInformation,
			int SystemInformationLength,
			ref int ReturnLength);
			
		[DllImport("kernel32", SetLastError=true, CharSet = CharSet.Ansi)]
		public static extern IntPtr LoadLibrary(
			string lpFileName);
			
		[DllImport("kernel32", SetLastError=true)]
		public static extern IntPtr LoadLibraryEx(
			string lpFileName,
			IntPtr hReservedNull,
			int dwFlags);
			
		[DllImport("kernel32.dll", SetLastError=true)]
		public static extern bool FreeLibrary(
			IntPtr hModule);
			
		[DllImport("kernel32", CharSet=CharSet.Ansi, ExactSpelling=true, SetLastError=true)]
		public static extern IntPtr GetProcAddress(
			IntPtr hModule,
			string procName);
			
		[DllImport("user32.dll")]
		public static extern IntPtr CreateAcceleratorTable(
			IntPtr lpaccl,
			int cEntries);
			
		[DllImport("user32.dll")]
		public static extern bool DestroyAcceleratorTable(
			IntPtr hAccel);
	}
"@