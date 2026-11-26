# The script PowerShell plays in the CLI/TUI scene (see stage.sh). pwsh loaded the
# reader's profile before it, so every color on screen is the theme's $PSStyle. It grows
# the staged repo from run.sh with fixed names, sizes and dates, then prints each
# command after a plain prompt and runs it for real. It ends on a build in progress,
# with a warning, an error and the progress bar drawn, and waits.
Set-Location ~/Inglenook
$null = New-Item -ItemType Directory -Force Ports/eza, Ports/fzf
Set-Content -NoNewline -Path install.sh -Value ('#' * 640)
chmod 755 install.sh
Set-Content -NoNewline -Path dist.zip -Value ('#' * 18432)
$null = New-Item -ItemType SymbolicLink -Path preview -Target Ports/fzf

# A build that reports as the real one does, with -Verbose and -Debug: one port has
# lost its template, so it fails there, and the others build on.
Set-Content -Path build.ps1 -Value @'
[CmdletBinding()] param()
Write-Verbose 'Palette 0.1.1, 9 ports'
Write-Debug 'moss l 0.52 -> 0.5'
Write-Warning 'screenshots of gnome-terminal are now stale'
Get-Item Ports/nano/template
Write-Progress -Activity 'Building ports' -Status 'gnome-terminal' -PercentComplete 40
while ($true) { Start-Sleep -Seconds 3600 }
'@
touch -h -d '2026-11-24 12:00' palette palette/palette.json Ports Ports/eza Ports/fzf build.ps1 install.sh dist.zip preview

function Invoke-SceneCommand([string]$Line) {
    Write-Host "PS ~/Inglenook> $Line"
    Invoke-Expression $Line | Out-Host
}

Clear-Host
Invoke-SceneCommand 'Get-ChildItem'
Invoke-SceneCommand 'Get-Item palette/palette.json | Format-List Name, Length'
Invoke-SceneCommand './build.ps1 -Verbose -Debug'
