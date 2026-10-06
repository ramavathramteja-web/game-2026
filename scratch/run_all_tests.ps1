$tests = Get-ChildItem -Path d:\the_missing_sun\src\tests\run_*.gd
foreach ($t in $tests) {
    Write-Host -NoNewline "$($t.Name): "
    $proc = Start-Process -FilePath "d:\the_missing_sun\godot.exe" -ArgumentList @("--headless", "--rendering-driver", "dummy", "--script", $t.FullName) -NoNewWindow -Wait -PassThru -RedirectStandardOutput "d:\the_missing_sun\scratch\test.log" -RedirectStandardError "d:\the_missing_sun\scratch\err.log"
    $log = Get-Content "d:\the_missing_sun\scratch\test.log" -Raw
    if ($log -match "ALL PASS") {
        Write-Host "ALL PASS"
    } else {
        Write-Host "EXIT $($proc.ExitCode)"
        Write-Host $log
        Get-Content "d:\the_missing_sun\scratch\err.log" | Select-Object -Last 10 | ForEach-Object { Write-Host "ERR: $_" }
    }
}
