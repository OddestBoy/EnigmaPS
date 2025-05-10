Write-Output "set-alias -name `"Enigma`" -value `"$PSScriptRoot\EnigmaPS.ps1`"" | Out-File $profile -Append -Encoding UTF8
Write-Host "Alias `"Engima`" set in PS Profile"
Write-Host "Open Powershell or Terminal and use command `"Enigma -h`""
Start-sleep 30
