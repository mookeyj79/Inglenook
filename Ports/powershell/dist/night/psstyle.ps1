# Inglenook for PowerShell $PSStyle: Inglenook Night.
# Source this from your PowerShell profile ($PROFILE). Palette 0.1.1, https://github.com/mookeyj79/Inglenook
# Colors what PowerShell formats itself: errors, warnings, verbose and debug messages,
# table headers and list labels, progress bars, and file names from Get-ChildItem.
# Needs PowerShell 7.4 or later; older versions skip it.

if ($PSVersionTable.PSVersion -lt '7.4') { return }

& {
    $fg = $PSStyle.Foreground

    $PSStyle.Formatting.Error = $fg.FromRgb(0xd9897e)
    $PSStyle.Formatting.ErrorAccent = $fg.FromRgb(0xb1aa9e)
    $PSStyle.Formatting.Warning = $fg.FromRgb(0xbdb377)
    $PSStyle.Formatting.Verbose = $fg.FromRgb(0x89b3d8)
    $PSStyle.Formatting.Debug = $fg.FromRgb(0xb1aa9e)
    $PSStyle.Formatting.FormatAccent = $fg.FromRgb(0x89b3d8)
    $PSStyle.Formatting.TableHeader = $fg.FromRgb(0x89b3d8)
    $PSStyle.Formatting.CustomTableHeaderLabel = $PSStyle.Italic + $fg.FromRgb(0x89b3d8)
    $PSStyle.Formatting.FeedbackName = $fg.FromRgb(0xb1aa9e)
    $PSStyle.Formatting.FeedbackText = $fg.FromRgb(0xd1c9bc)
    $PSStyle.Formatting.FeedbackAction = $fg.FromRgb(0x89b3d8)

    $PSStyle.Progress.Style = $fg.FromRgb(0x89b3d8)

    $PSStyle.FileInfo.Directory = $PSStyle.Bold + $fg.FromRgb(0x89b3d8)
    $PSStyle.FileInfo.SymbolicLink = $fg.FromRgb(0x72bdbd)
    $PSStyle.FileInfo.Executable = $PSStyle.Bold + $fg.FromRgb(0x91bc88)
    foreach ($ext in '.zip', '.tgz', '.gz', '.tar', '.nupkg', '.cab', '.7z') {
        $PSStyle.FileInfo.Extension[$ext] = $fg.FromRgb(0xb66f75)
    }
    foreach ($ext in '.ps1', '.psd1', '.psm1', '.ps1xml') {
        $PSStyle.FileInfo.Extension[$ext] = $fg.FromRgb(0xd4a2aa)
    }
}
