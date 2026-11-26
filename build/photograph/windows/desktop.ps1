#requires -Version 7.0
<#
.SYNOPSIS
    Sets the scene's desktop on a hosted Windows runner, for one variant.

.DESCRIPTION
    photograph.ps1 runs this before a variant's takes, only on a GitHub-hosted
    runner: it changes system settings no one wants changed on their own PC.
    Safe to run again in the same job.

    Windows' own window shadow (off on Windows Server), the rounded corners of a
    Windows 11 desktop (DWM ForceEffectMode 2 and a DWM restart; still no
    acrylic or Mica on a runner), the screen size (set after the restart, which
    drops it to 1024x768), the variant's app and system mode with transparency
    effects off, the backdrop (a plain fill or a wallpaper), no blinking caret,
    and BlexMono Nerd Font from the pins.
#>
param(
    [Parameter(Mandatory)]$Scene,
    [Parameter(Mandatory)][string]$RepoRoot,
    [Parameter(Mandatory)]$Font,
    [Parameter(Mandatory)][string]$Work
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'win32.ps1')

$WM_SETTINGCHANGE = 0x1A
$WM_FONTCHANGE = 0x1D
$width, $height = [int[]]($Scene.SCREEN -split 'x')

# Windows' window shadow, and the UI effects it hangs on.
$null = [InglenookWin32]::SystemParametersInfoPtr(0x103F, 0, [IntPtr]1, 3)   # SPI_SETUIEFFECTS
$null = [InglenookWin32]::SystemParametersInfoPtr(0x1025, 0, [IntPtr]1, 3)   # SPI_SETDROPSHADOW
[InglenookWin32]::Broadcast($WM_SETTINGCHANGE, 'VisualEffects')

# Rounded corners, as on a Windows 11 desktop. DWM restarts itself when stopped.
$dwmKey = 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm'
$mode = try { Get-ItemPropertyValue -Path $dwmKey -Name ForceEffectMode } catch { $null }
if ($mode -ne 2) {
    Set-ItemProperty -Path $dwmKey -Name ForceEffectMode -Value 2 -Type DWord
    $old = @(Get-Process -Name dwm -ErrorAction SilentlyContinue | ForEach-Object Id)
    foreach ($id in $old) { Stop-Process -Id $id -Force }
    $clock = [Diagnostics.Stopwatch]::StartNew()
    while (-not @(Get-Process -Name dwm -ErrorAction SilentlyContinue | Where-Object { $_.Id -notin $old }).Count) {
        if ($clock.Elapsed.TotalSeconds -gt 60) { throw 'photograph: DWM did not come back within 60 s of its restart.' }
        Start-Sleep -Milliseconds 250
    }
    Start-Sleep -Seconds 3
}

# The screen, after any DWM restart.
$rc = [InglenookWin32]::SetScreen($width, $height)
if ($rc -ne 0 -or [InglenookWin32]::Screen() -ne $Scene.SCREEN) {
    throw "photograph: the runner did not take the screen size $($Scene.SCREEN) (ChangeDisplaySettings $rc, now $([InglenookWin32]::Screen()))."
}

# The variant's mode, for apps and for Windows itself. Solid surfaces only: transparency effects off.
$personalize = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
New-Item -Path $personalize -Force -ErrorAction SilentlyContinue | Out-Null
$light = [int]($Scene.MODE -eq 'light')
Set-ItemProperty -Path $personalize -Name AppsUseLightTheme -Value $light -Type DWord
Set-ItemProperty -Path $personalize -Name SystemUsesLightTheme -Value $light -Type DWord
Set-ItemProperty -Path $personalize -Name EnableTransparency -Value 0 -Type DWord
[InglenookWin32]::Broadcast($WM_SETTINGCHANGE, 'ImmersiveColorSet')

# The backdrop: a wallpaper filling the screen, or no wallpaper over a plain desktop color.
if ($Scene.BACKDROP_KIND -eq 'image') {
    $wallpaper = Join-Path $RepoRoot $Scene.BACKDROP
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10'
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'
    if (-not [InglenookWin32]::SystemParametersInfoW(0x14, 0, $wallpaper, 3)) { throw "photograph: Windows did not take the wallpaper $wallpaper." }
}
else {
    $hex = [string]$Scene.BACKDROP
    $r, $g, $b = foreach ($i in 1, 3, 5) { [Convert]::ToInt32($hex.Substring($i, 2), 16) }
    Set-ItemProperty -Path 'HKCU:\Control Panel\Colors' -Name Background -Value "$r $g $b"
    if (-not [InglenookWin32]::SystemParametersInfoW(0x14, 0, '', 3)) { throw 'photograph: Windows did not drop the wallpaper.' }
    if (-not [InglenookWin32]::SetDesktopColor($r, $g, $b)) { throw "photograph: Windows did not take the desktop color $hex." }
}

# No blinking caret: terminals and editors blink at the system's rate.
$null = [InglenookWin32]::SetCaretBlinkTime([uint32]::MaxValue)
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name CursorBlinkRate -Value '-1'

# BlexMono Nerd Font, checked against its pin, for every user.
$fontKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
if (-not (Get-ItemProperty -Path $fontKey -Name 'BlexMonoNerdFontMono-Regular (TrueType)' -ErrorAction SilentlyContinue)) {
    $zip = Join-Path $Work 'font.zip'
    Invoke-WebRequest -Uri $Font.url -OutFile $zip
    if ((Get-FileHash -Path $zip -Algorithm SHA256).Hash -ne $Font.sha256) { throw "photograph: the font at $($Font.url) does not match its pinned sha256." }
    $dir = Join-Path $Work 'font'
    Expand-Archive -Path $zip -DestinationPath $dir -Force
    foreach ($f in @(Get-ChildItem -Path $dir -Filter 'BlexMonoNerdFontMono-*.ttf')) {
        $dest = Join-Path $env:WINDIR 'Fonts' $f.Name
        Copy-Item -Path $f.FullName -Destination $dest -Force
        Set-ItemProperty -Path $fontKey -Name "$($f.BaseName) (TrueType)" -Value $f.Name
        $null = [InglenookWin32]::AddFontResourceW($dest)
    }
    [InglenookWin32]::Broadcast($WM_FONTCHANGE, $null)
}
