# {{meta.name}} for PowerShell $PSStyle: {{variant.name}}.
# Source this from your PowerShell profile ($PROFILE). Palette {{meta.version}}, {{meta.repository}}
# Colors what PowerShell formats itself: errors, warnings, verbose and debug messages,
# table headers and list labels, progress bars, and file names from Get-ChildItem.
# Needs PowerShell 7.4 or later; older versions skip it.

if ($PSVersionTable.PSVersion -lt '7.4') { return }

& {
    $fg = $PSStyle.Foreground

    $PSStyle.Formatting.Error = $fg.FromRgb(0x{{error|nohash}})
    $PSStyle.Formatting.ErrorAccent = $fg.FromRgb(0x{{dim|nohash}})
    $PSStyle.Formatting.Warning = $fg.FromRgb(0x{{warning|nohash}})
    $PSStyle.Formatting.Verbose = $fg.FromRgb(0x{{info|nohash}})
    $PSStyle.Formatting.Debug = $fg.FromRgb(0x{{dim|nohash}})
    $PSStyle.Formatting.FormatAccent = $fg.FromRgb(0x{{info|nohash}})
    $PSStyle.Formatting.TableHeader = $fg.FromRgb(0x{{info|nohash}})
    $PSStyle.Formatting.CustomTableHeaderLabel = $PSStyle.Italic + $fg.FromRgb(0x{{info|nohash}})
    $PSStyle.Formatting.FeedbackName = $fg.FromRgb(0x{{dim|nohash}})
    $PSStyle.Formatting.FeedbackText = $fg.FromRgb(0x{{text|nohash}})
    $PSStyle.Formatting.FeedbackAction = $fg.FromRgb(0x{{info|nohash}})

    $PSStyle.Progress.Style = $fg.FromRgb(0x{{info|nohash}})

    $PSStyle.FileInfo.Directory = $PSStyle.Bold + $fg.FromRgb(0x{{ansi.blue|nohash}})
    $PSStyle.FileInfo.SymbolicLink = $fg.FromRgb(0x{{reference|nohash}})
    $PSStyle.FileInfo.Executable = $PSStyle.Bold + $fg.FromRgb(0x{{ansi.green|nohash}})
    foreach ($ext in '.zip', '.tgz', '.gz', '.tar', '.nupkg', '.cab', '.7z') {
        $PSStyle.FileInfo.Extension[$ext] = $fg.FromRgb(0x{{oxblood|nohash}})
    }
    foreach ($ext in '.ps1', '.psd1', '.psm1', '.ps1xml') {
        $PSStyle.FileInfo.Extension[$ext] = $fg.FromRgb(0x{{rosewood|nohash}})
    }
}
