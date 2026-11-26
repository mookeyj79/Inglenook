#requires -Version 7.0
<#
.SYNOPSIS
    One take of one variant on a hosted Windows runner, after desktop.ps1.

.DESCRIPTION
    photograph.ps1 writes <Work>/steps.ps1 (the recipe's apply, stage and launch
    steps) and runs this. It minimizes every other window (the runner's own
    agent runs in a Windows Terminal), runs the steps, polls for the window,
    moves it to the middle of the screen and focuses it, then waits for two
    equal screen grabs 300 ms apart. It leaves the settled screen in
    <Work>/root.png and the frame as drawn in <Work>/frame.json. All cropping
    happens outside.

    The window is the frontmost match of the recipe's window that belongs to an
    exe not running before the take (Find-ShotWindow). At the end, whatever
    happens, it stops by process id what the take started: the window's process
    and its children, and every process from an exe that was not running
    before, outside the Windows folder. Never by name.
#>
param(
    [Parameter(Mandatory)]$Scene,
    [Parameter(Mandatory)][string]$Work
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'win32.ps1')
Import-Module (Join-Path $PSScriptRoot '..' '..' 'lib' 'Photographer.psm1')

$timeout = [int]$Scene.TIMEOUT
$width, $height = [int[]]($Scene.SCREEN -split 'x')
$desktop = @('Progman', 'WorkerW', 'Shell_TrayWnd', 'Shell_SecondaryTrayWnd')

function Get-ExePath([int]$ProcessId) {
    try { return (Get-Process -Id $ProcessId -ErrorAction Stop).Path } catch { return $null }
}

function Get-ShotWindows {
    foreach ($h in [InglenookWin32]::Visible()) {
        $procId = [uint32]0
        $null = [InglenookWin32]::GetWindowThreadProcessId($h, [ref]$procId)
        [pscustomobject]@{ Handle = $h; Class = [InglenookWin32]::Class($h); Title = [InglenookWin32]::Text($h); ProcessId = [int]$procId; Path = Get-ExePath $procId }
    }
}

function Get-Grab {
    $bmp = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try { $g.CopyFromScreen(0, 0, 0, 0, [System.Drawing.Size]::new($width, $height)) } finally { $g.Dispose() }
    return $bmp
}

function Get-GrabHash($Bitmap) {
    $rect = [System.Drawing.Rectangle]::new(0, 0, $Bitmap.Width, $Bitmap.Height)
    $data = $Bitmap.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, $Bitmap.PixelFormat)
    try {
        $bytes = [byte[]]::new($data.Stride * $data.Height)
        [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
    }
    finally { $Bitmap.UnlockBits($data) }
    return Get-Sha256 $bytes
}

function Stop-TakeProcesses($Window, [string[]]$Before, [datetime]$Since) {
    $ids = [System.Collections.Generic.HashSet[int]]::new()
    $all = @(Get-CimInstance -ClassName Win32_Process)
    if ($Window) {
        # The window's process and everything under it.
        $queue = [System.Collections.Generic.Queue[int]]::new()
        $queue.Enqueue($Window.ProcessId)
        while ($queue.Count) {
            $id = $queue.Dequeue()
            if (-not $ids.Add($id)) { continue }
            foreach ($c in $all) { if ($c.ParentProcessId -eq $id -and $c.CreationDate -ge $Since) { $queue.Enqueue([int]$c.ProcessId) } }
        }
    }
    foreach ($p in $all) {
        if ($p.ExecutablePath -and $p.CreationDate -ge $Since -and $Before -notcontains $p.ExecutablePath -and
            -not $p.ExecutablePath.StartsWith($env:WINDIR, [StringComparison]::OrdinalIgnoreCase)) { $null = $ids.Add([int]$p.ProcessId) }
    }
    $ids.Remove($PID) | Out-Null
    $names = @(foreach ($id in $ids) { ($all | Where-Object ProcessId -eq $id | Select-Object -First 1).Name })
    if ($ids.Count) { Write-Host "  stopping what the take started: $($names -join ', ')" }
    foreach ($id in $ids) { Stop-Process -Id $id -Force -ErrorAction SilentlyContinue }
    if ($ids.Count) { Start-Sleep -Seconds 1 }
}

$since = Get-Date
$before = @(Get-Process | ForEach-Object { try { $_.Path } catch { $null } } | Where-Object { $_ } | Sort-Object -Unique)
$found = $null
try {
    # A calm desktop: every other window minimized, the pointer in a corner.
    foreach ($h in [InglenookWin32]::Visible()) {
        if ([InglenookWin32]::Class($h) -notin $desktop) { $null = [InglenookWin32]::ShowWindow($h, 6) }   # SW_MINIMIZE
    }
    $null = [InglenookWin32]::SetCursorPos(2, 2)

    $out = @(& pwsh -NoProfile -NonInteractive -File (Join-Path $Work 'steps.ps1') 2>&1 | ForEach-Object { "$_" })
    if ($LASTEXITCODE -ne 0) { throw ($out -join "`n") }

    $want = [pscustomobject]@{ Kind = $Scene.WINDOW_KIND; Match = $Scene.WINDOW_MATCH }
    $clock = [Diagnostics.Stopwatch]::StartNew()
    while (-not $found) {
        if ($clock.Elapsed.TotalSeconds -ge $timeout) {
            $logs = @(foreach ($log in @(Get-ChildItem -Path $Work -Filter 'step-*-launch-*.log*' -ErrorAction SilentlyContinue)) {
                if ($log.Length) { "$($log.Name):"; Get-Content -Path $log.FullName -Tail 20 | ForEach-Object { "    $_" } }
            })
            throw ((@($logs) + "photograph: no window matching $($Scene.WINDOW_KIND) `"$($Scene.WINDOW_MATCH)`" after ${timeout}s. Check window and launch in $($Scene.RECIPE).") -join "`n")
        }
        Start-Sleep -Milliseconds 200
        $found = Find-ShotWindow -Windows @(Get-ShotWindows | Where-Object { -not [InglenookWin32]::IsIconic($_.Handle) }) -Before $before -Window $want
    }

    # Wait for the app to finish drawing at its own size, then center the frame as drawn.
    Start-Sleep -Seconds 2
    $outer = [InglenookWin32+RECT]::new()
    $null = [InglenookWin32]::GetWindowRect($found.Handle, [ref]$outer)
    $frame = [InglenookWin32]::Frame($found.Handle)
    $fw = $frame.Right - $frame.Left; $fh = $frame.Bottom - $frame.Top
    $x = [int][math]::Floor(($width - $fw) / 2) - ($frame.Left - $outer.Left)
    $y = [int][math]::Floor(($height - $fh) / 2) - ($frame.Top - $outer.Top)
    $null = [InglenookWin32]::SetWindowPos($found.Handle, [IntPtr]::Zero, $x, $y, 0, 0, 0x0001 -bor 0x0004)   # SWP_NOSIZE, SWP_NOZORDER
    for ($i = 0; $i -lt 10 -and [InglenookWin32]::GetForegroundWindow() -ne $found.Handle; $i++) {
        $null = [InglenookWin32]::Focus($found.Handle)
        Start-Sleep -Milliseconds 300
    }
    if ([InglenookWin32]::GetForegroundWindow() -ne $found.Handle) { throw "photograph: the window would not take the focus. Something in $($Scene.RECIPE) covers it." }

    # Wait for pixels, not time: two equal grabs 300 ms apart.
    $null = [InglenookWin32]::DwmFlush()
    $clock.Restart()
    $a = Get-Grab; $n = 0
    try {
        while ($true) {
            Start-Sleep -Milliseconds 300
            $b = Get-Grab; $n++
            if ((Get-GrabHash $a) -eq (Get-GrabHash $b)) { break }
            $a.Dispose(); $a = $b
            if ($clock.Elapsed.TotalSeconds -ge $timeout) { throw "photograph: the screen never settled after ${timeout}s. Something in $($Scene.RECIPE) keeps moving (a blinking cursor?)." }
        }
        $b.Save((Join-Path $Work 'root.png'), [System.Drawing.Imaging.ImageFormat]::Png)
        $b.Dispose()
    }
    finally { $a.Dispose() }

    $frame = [InglenookWin32]::Frame($found.Handle)
    $f = [ordered]@{ X = $frame.Left; Y = $frame.Top; Width = $frame.Right - $frame.Left; Height = $frame.Bottom - $frame.Top }
    Set-Content -Path (Join-Path $Work 'frame.json') -Value (ConvertTo-Json $f -Compress)
    Write-Output "settled after $n grabs, frame $($f.Width)x$($f.Height)+$($f.X)+$($f.Y), window of $($found.Path)"
}
finally {
    Stop-TakeProcesses -Window $found -Before $before -Since $since
}
