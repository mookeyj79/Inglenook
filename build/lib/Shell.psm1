# Shell files: what a port ships for a tool that takes its colors from the
# shell. A template/<tool>.env holds NAME=value lines once; the build turns it
# into <tool>.sh (bash and zsh) and <tool>.ps1 (PowerShell), so both shells get
# the same values. The checks ask Test-ShellFile whether a generated file parses
# and sources cleanly in its shells.

Set-StrictMode -Version Latest

$NamePattern = '^[A-Za-z_][A-Za-z0-9_]*$'

function ConvertFrom-EnvText {
    <#
    .SYNOPSIS
        An expanded .env template as @{ sh; ps1 }: the text of each file.
    .DESCRIPTION
        Blank lines and # comments are kept as they are. Every other line is
        NAME=value, written as export NAME='value' and $env:NAME = 'value'.
        Throws, naming $Source and the line, on any other line or on a value
        with a single quote.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text, [string]$Source = '.env')
    $sh = [System.Collections.Generic.List[string]]::new()
    $ps1 = [System.Collections.Generic.List[string]]::new()
    $lines = $Text -split "`r?`n"
    $trailing = $Text -match "`n\z"
    if ($trailing) { $lines = $lines[0..($lines.Count - 2)] }
    $n = 0
    foreach ($line in $lines) {
        $n++
        if ($line -match '^\s*(#.*)?$') { $sh.Add($line); $ps1.Add($line); continue }
        $eq = $line.IndexOf('=')
        $name = if ($eq -gt 0) { $line.Substring(0, $eq) } else { '' }
        if ($name -notmatch $NamePattern) { throw "${Source}:$n is not NAME=value or a # comment: '$line'." }
        $value = $line.Substring($eq + 1)
        if ($value.Contains("'")) { throw "${Source}:$n has a single quote in its value, which the shell files cannot quote." }
        $sh.Add("export $name='$value'")
        $ps1.Add("`$env:$name = '$value'")
    }
    $end = if ($trailing) { "`n" } else { '' }
    return @{ sh = (($sh -join "`n") + $end); ps1 = (($ps1 -join "`n") + $end) }
}

function Invoke-Shell([string]$Exe, [string[]]$Arguments) {
    # Runs a shell with no startup files of its own. Returns @{ Exit; Text }.
    $saved = @{ BASH_ENV = $env:BASH_ENV; ENV = $env:ENV }
    $env:BASH_ENV = $null; $env:ENV = $null
    try { $out = & $Exe @Arguments 2>&1; $code = $LASTEXITCODE }
    finally { $env:BASH_ENV = $saved.BASH_ENV; $env:ENV = $saved.ENV }
    return @{ Exit = $code; Text = (@($out | ForEach-Object { "$_" }) -join ' ').Trim() }
}

function Test-ShellFile {
    <#
    .SYNOPSIS
        Whether a shell file parses and sources cleanly in every shell it is
        for. Returns @{ Problems; Skipped }.
    .DESCRIPTION
        .sh is for bash and zsh, .zsh for zsh, .ps1 for PowerShell. Each shell
        first checks the syntax (bash -n, zsh -n, the PowerShell parser), then
        sources the file in a fresh session with no startup files: it must
        exit 0 and print nothing. A shell that is not installed is listed in
        Skipped instead. Other extensions return no problems.
    #>
    param([Parameter(Mandatory)][string]$Path)
    $problems = [System.Collections.Generic.List[string]]::new()
    $skipped = [System.Collections.Generic.List[string]]::new()
    $shells = switch ([System.IO.Path]::GetExtension($Path).ToLowerInvariant()) {
        '.sh'  { 'bash', 'zsh' }
        '.zsh' { 'zsh' }
        '.ps1' { 'pwsh' }
        default { @() }
    }
    foreach ($shell in $shells) {
        if ($shell -eq 'pwsh') {
            $tokens = $null; $errors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
            if ($errors) { $problems.Add("PowerShell: does not parse: $($errors[0].Message) (line $($errors[0].Extent.StartLineNumber))."); continue }
            $command = ". '" + ($Path -replace "'", "''") + "'"
            $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($command))
            $r = Invoke-Shell (Get-Process -Id $PID).Path @('-NoProfile', '-NonInteractive', '-EncodedCommand', $encoded)
            if ($r.Exit -ne 0 -or $r.Text) { $problems.Add("PowerShell: sourcing it exits $($r.Exit) and prints: $($r.Text)") }
            continue
        }
        $exe = Get-Command $shell -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $exe) { $skipped.Add($shell); continue }
        $noRc = if ($shell -eq 'bash') { @('--norc', '--noprofile') } else { @('-f') }
        $r = Invoke-Shell $exe.Source (@($noRc) + @('-n', $Path))
        if ($r.Exit -ne 0 -or $r.Text) { $problems.Add("${shell}: does not parse: $($r.Text)"); continue }
        $r = Invoke-Shell $exe.Source (@($noRc) + @('-c', '. "$1"', $shell, $Path))
        if ($r.Exit -ne 0 -or $r.Text) { $problems.Add("${shell}: sourcing it exits $($r.Exit) and prints: $($r.Text)") }
    }
    return @{ Problems = $problems; Skipped = $skipped }
}

Export-ModuleMember -Function ConvertFrom-EnvText, Test-ShellFile
