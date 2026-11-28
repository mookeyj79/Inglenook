# Inglenook for PowerShell $PSStyle: Inglenook Day.
# Source this from your PowerShell profile ($PROFILE). Palette 1.0.0, https://github.com/mookeyj79/Inglenook
# Colors what PowerShell formats itself: errors, warnings, verbose and debug messages,
# table headers and list labels, progress bars, and file names from Get-ChildItem.
# Needs PowerShell 7.4 or later; older versions skip it.

if ($PSVersionTable.PSVersion -lt '7.4') { return }

& {
    $fg = $PSStyle.Foreground

    $PSStyle.Formatting.Error = $fg.FromRgb(0xa04037)
    $PSStyle.Formatting.ErrorAccent = $fg.FromRgb(0x49545d)
    $PSStyle.Formatting.Warning = $fg.FromRgb(0x706416)
    $PSStyle.Formatting.Verbose = $fg.FromRgb(0x326893)
    $PSStyle.Formatting.Debug = $fg.FromRgb(0x49545d)
    $PSStyle.Formatting.FormatAccent = $fg.FromRgb(0x326893)
    $PSStyle.Formatting.TableHeader = $fg.FromRgb(0x326893)
    $PSStyle.Formatting.CustomTableHeaderLabel = $PSStyle.Italic + $fg.FromRgb(0x326893)
    $PSStyle.Formatting.FeedbackName = $fg.FromRgb(0x49545d)
    $PSStyle.Formatting.FeedbackText = $fg.FromRgb(0x2d373f)
    $PSStyle.Formatting.FeedbackAction = $fg.FromRgb(0x326893)

    $PSStyle.Progress.Style = $fg.FromRgb(0x326893)

    $PSStyle.FileInfo.Directory = $PSStyle.Bold + $fg.FromRgb(0x326893)
    $PSStyle.FileInfo.SymbolicLink = $fg.FromRgb(0x017272)
    $PSStyle.FileInfo.Executable = $PSStyle.Bold + $fg.FromRgb(0x407135)
    foreach ($ext in '.zip', '.tgz', '.gz', '.tar', '.nupkg', '.cab', '.7z') {
        $PSStyle.FileInfo.Extension[$ext] = $fg.FromRgb(0x7e2e39)
    }
    foreach ($ext in '.ps1', '.psd1', '.psm1', '.ps1xml') {
        $PSStyle.FileInfo.Extension[$ext] = $fg.FromRgb(0x905560)
    }
}
