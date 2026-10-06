$proc = Start-Process -FilePath "D:\the_missing_sun\godot.exe" -ArgumentList '--path "D:\the_missing_sun" "res://src/levels/L1_DarkCity.tscn"' -WorkingDirectory "D:\the_missing_sun" -PassThru

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Focus {
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern void SwitchToThisWindow(IntPtr hWnd, bool fAltTab);
}
"@ -ErrorAction SilentlyContinue

for ($i = 0; $i -lt 15; $i++) {
    Start-Sleep -Milliseconds 400
    $proc.Refresh()
    if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
        [Win32Focus]::ShowWindow($proc.MainWindowHandle, 9)
        [Win32Focus]::SetForegroundWindow($proc.MainWindowHandle)
        [Win32Focus]::SwitchToThisWindow($proc.MainWindowHandle, $true)
        Write-Host "Game window brought to front. HWND: $($proc.MainWindowHandle)"
        break
    }
}

$proc.WaitForExit()
