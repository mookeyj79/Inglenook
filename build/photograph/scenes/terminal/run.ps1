# The terminal scene for Windows terminals: the same staged slice as run.sh, line for
# line, in PowerShell. Fixed text, never live output. Colors are ANSI slots only.
# Launch it with: pwsh -NoLogo -NoProfile -File "$env:INGLENOOK_SCENE/run.ps1"
$e = [char]27
$r = "$e[0m"; $b = "$e[1m"; $red = "$e[31m"; $green = "$e[32m"; $yellow = "$e[33m"; $blue = "$e[34m"; $magenta = "$e[35m"; $cyan = "$e[36m"; $muted = "$e[90m"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$lines = [System.Collections.Generic.List[string]]::new()
function Add-Prompt([string]$Command) { $lines.Add("$blue~/Inglenook$r on ${magenta}main$r `$ $Command") }

Add-Prompt 'git log --oneline -3'
$lines.Add("${yellow}b60388e$r ${cyan}(${b}HEAD -> ${green}main$r${cyan})$r Add Pin to the glossary ${muted}2 days ago$r")
$lines.Add("${yellow}f4960df$r Add the screenshot terms to the glossary ${muted}3 days ago$r")
$lines.Add("${yellow}1e7c435$r Drop the Layout section from the VS Code install guide ${muted}4 days ago$r")
Add-Prompt 'git diff palette/palette.json'
$lines.Add("${b}diff --git a/palette/palette.json b/palette/palette.json$r")
$lines.Add("${cyan}@@ -2,7 +2,7 @@$r")
$lines.Add('   "meta": {')
$lines.Add("${red}-    `"version`": `"0.1.0`",$r")
$lines.Add("${green}+    `"version`": `"0.1.1`",$r")
$lines.Add("${cyan}@@ -85,7 +85,7 @@$r")
$lines.Add('         "moss": {')
$lines.Add("${red}-          `"l`": 0.52,$r")
$lines.Add("${green}+          `"l`": 0.5,$r")
Add-Prompt 'pwsh build/check.ps1'
$lines.Add("Palette      ${green}ok$r")
$lines.Add("Contrast     ${green}ok$r")
$lines.Add("Drift        ${red}${b}FAIL$r")
$lines.Add("${red}FAIL: Drift: Ports/gnome-terminal/dist/day/install.sh is out of date. Run build/build.ps1.$r")
Add-Prompt 'pwsh build/build.ps1'
$lines.Add("gnome-terminal     ${yellow}changed$r")
$lines.Add("preview            ${yellow}changed$r")
$lines.Add("windows-terminal   ${muted}version stamp only$r")
$lines.Add("${yellow}warning: screenshots of gnome-terminal and preview are now stale$r")

# One write, CR LF line ends, and the cursor left on the last prompt.
[Console]::Write("$e[H$e[2J" + ($lines -join "`r`n") + "`r`n$blue~/Inglenook$r on ${magenta}main$r `$ ")
while ($true) { Start-Sleep -Seconds 3600 }
