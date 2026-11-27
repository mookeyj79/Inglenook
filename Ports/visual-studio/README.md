# Inglenook for Visual Studio

**Tier:** 2 Partial\
**Variants:** Inglenook Day, Inglenook Night\
**Tested with:** Not tested yet

This is the Windows IDE, Visual Studio 2022 or 2026. For Visual Studio Code, see [Inglenook for Visual Studio Code](../vscode/README.md).

Each variant is its own small Visual Studio extension, shipped as source: `dist/day/` is **Inglenook Day** and `dist/night/` is **Inglenook Night**. You build each one into a `.vsix` file once, then install it. The theme colors the whole IDE: menus, tool windows, tabs, the status bar, dialogs, and the code editor.

## Before you start

- Visual Studio 2022 (17.0 or later) or Visual Studio 2026, Community, Professional, or Enterprise.
- The **Visual Studio extension development** workload, to build the extensions:
  1. Open **Visual Studio Installer** from the Start menu.
  2. Next to your Visual Studio, click **Modify**.
  3. On the **Workloads** tab, check **Visual Studio extension development**, then click **Modify**.

## Install

1. Download or clone this repo.
2. Copy the folder `Ports/visual-studio/dist/day` to a folder of your own, such as `C:\Themes\inglenook-day`. Building writes `bin` and `obj` folders next to the files, so keep them out of the repo.
3. Copy `Ports/visual-studio/dist/night` the same way, such as to `C:\Themes\inglenook-night`.
4. In Visual Studio, choose **File** > **Open** > **Project/Solution** and open `C:\Themes\inglenook-day\inglenook-day.csproj`.
5. Choose **Build** > **Build Solution**. The first build downloads one NuGet package, so it needs an internet connection. When it finishes, the Output window says "Build succeeded".
6. Do the same for Night: open `C:\Themes\inglenook-night\inglenook-night.csproj` and choose **Build** > **Build Solution**.
7. Close Visual Studio.
8. In File Explorer, open `C:\Themes\inglenook-day\bin\Release` and double-click `inglenook-day.vsix`. The VSIX Installer opens. Follow its steps, then close it when it says the install is complete.
9. Do the same with `C:\Themes\inglenook-night\bin\Release\inglenook-night.vsix`.
10. Open Visual Studio. Choose **Tools** > **Theme** > **Inglenook Day** or **Inglenook Night**.

Steps 4 to 6 can also be done from **Developer PowerShell for VS**, in each folder:

```
msbuild -restore -p:Configuration=Release inglenook-day.csproj
```

Files to use:

- Inglenook Day: `dist/day/` (`inglenook-day.vstheme`, `inglenook-day.csproj`, `source.extension.vsixmanifest`, `Properties/AssemblyInfo.cs`, `LICENSE`, `LICENSE-catppuccin`)
- Inglenook Night: `dist/night/` (`inglenook-night.vstheme`, `inglenook-night.csproj`, `source.extension.vsixmanifest`, `Properties/AssemblyInfo.cs`, `LICENSE`, `LICENSE-catppuccin`)

## Set the font

Inglenook uses [IBM Plex Mono](https://github.com/IBM/plex). Where the app shows icons, use [BlexMono Nerd Font](https://www.nerdfonts.com/font-downloads) instead, the same font with icons added. If it is not installed yet, follow [Font](../../README.md#font) in the main README.

1. Choose **Tools** > **Options**, then **Environment** > **Fonts and Colors**.
2. Under **Show settings for**, pick **Text Editor**.
3. Under **Font**, pick **IBM Plex Mono**, then click **OK** if the page has one.

## Check that it worked

The title bar, menus, and tool windows turn to the theme's warm neutrals, and in a code file, keywords, strings, and types each take their own soft color. The selected tab and the caret glow amber.

## Switch between Day and Night

1. Choose **Tools** > **Theme**.
2. Pick **Inglenook Day** or **Inglenook Night**.

## Uninstall

1. Choose **Tools** > **Theme** and pick one of Visual Studio's own themes, such as **Dark** or **Light**.
2. Choose **Extensions** > **Manage Extensions**, then open the **Installed** list.
3. Find **Inglenook Day**, click **Uninstall**, and do the same for **Inglenook Night**.
4. Close Visual Studio. The changes run when it closes; follow the installer's steps if it asks.

## Troubleshooting

- **The theme is not in Tools > Theme**: close every Visual Studio window and open it again. If it is still missing, check **Extensions** > **Manage Extensions** > **Installed**: the extension may be disabled there.
- **The build says the project type is not supported**: the **Visual Studio extension development** workload is missing. See [Before you start](#before-you-start).
- **Some code colors stay the same after switching themes**: colors you changed by hand in **Tools** > **Options** > **Environment** > **Fonts and Colors** win over any theme. In that page, pick **Text Editor** and click **Use Defaults**.

## Known limits

- Parts of Visual Studio that the theme does not name keep the colors of Visual Studio's own Light theme (Day) or Dark theme (Night). Most of these are tools you open rarely, such as the profilers, designers, and some Azure and database windows.
- Breakpoints and the current line while debugging use a soft wash behind the code, so their markers in the margin are paler than Visual Studio's own.
- Rainbow braces from extensions are all one color, the same as other punctuation.

## Sources

- [VSIX Color Compiler](https://learn.microsoft.com/visualstudio/extensibility/internals/vsix-color-compiler): the theme file format and the built-in theme IDs
- [Modernize Visual Studio theme colors](https://learn.microsoft.com/visualstudio/extensibility/migration/modernize-theme-colors): the Visual Studio 2026 color set and fallback themes
- [Customize your Visual Studio IDE settings](https://learn.microsoft.com/visualstudio/ide/personalizing-the-visual-studio-ide): choosing a theme and the font
- [Find and manage extension packages](https://learn.microsoft.com/visualstudio/ide/finding-and-using-visual-studio-extensions): installing a `.vsix` and uninstalling it
- The extension project and the list of themed colors are adapted from [Catppuccin for Visual Studio](https://github.com/catppuccin/visual-studio), [MIT License](https://github.com/catppuccin/visual-studio/blob/main/LICENSE), Copyright (c) 2021 Catppuccin. Every color is Inglenook's own. Its license notice ships in each extension as `LICENSE-catppuccin`.
