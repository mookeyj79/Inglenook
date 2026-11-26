# The Windows calls the Photographer makes, for desktop.ps1 and shoot.ps1. Dot-source it.
Add-Type -AssemblyName System.Drawing
if (-not ('InglenookWin32' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class InglenookWin32 {
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)] public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string DeviceName;
        public ushort SpecVersion, DriverVersion, Size, DriverExtra; public uint Fields;
        public int PositionX, PositionY; public uint DisplayOrientation, DisplayFixedOutput;
        public short Color, Duplex, YResolution, TTOption, Collate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string FormName;
        public ushort LogPixels; public uint BitsPerPel, PelsWidth, PelsHeight, DisplayFlags, DisplayFrequency;
        public uint ICMMethod, ICMIntent, MediaType, DitherType, Reserved1, Reserved2, PanningWidth, PanningHeight;
    }
    delegate bool EnumProc(IntPtr h, IntPtr l);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern bool EnumDisplaySettingsW(string d, int n, ref DEVMODE m);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int ChangeDisplaySettingsW(ref DEVMODE m, int f);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern bool SystemParametersInfoW(uint action, uint param, string value, uint flags);
    [DllImport("user32.dll", EntryPoint = "SystemParametersInfoW")] public static extern bool SystemParametersInfoPtr(uint action, uint param, IntPtr value, uint flags);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr SendMessageTimeoutW(IntPtr h, uint m, IntPtr w, string l, uint f, uint t, out IntPtr r);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p, IntPtr l);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowTextW(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassNameW(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern bool SetCaretBlinkTime(uint ms);
    [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
    [DllImport("dwmapi.dll")] static extern int DwmGetWindowAttribute(IntPtr h, int a, out RECT r, int n);
    [DllImport("dwmapi.dll")] public static extern int DwmFlush();
    [DllImport("gdi32.dll", CharSet = CharSet.Unicode)] public static extern int AddFontResourceW(string file);
    [DllImport("user32.dll")] static extern bool SetSysColors(int n, int[] elements, uint[] colors);

    // The desktop color (COLOR_DESKTOP), shown where there is no wallpaper.
    public static bool SetDesktopColor(int r, int g, int b) {
        return SetSysColors(1, new int[] { 1 }, new uint[] { (uint)(r | (g << 8) | (b << 16)) });
    }

    // 0 when the screen now has this size; otherwise ChangeDisplaySettings' error.
    public static int SetScreen(int w, int h) {
        var m = new DEVMODE(); m.Size = (ushort)Marshal.SizeOf(m);
        EnumDisplaySettingsW(null, -1, ref m);
        m.PelsWidth = (uint)w; m.PelsHeight = (uint)h; m.Fields = 0x80000 | 0x100000;
        return ChangeDisplaySettingsW(ref m, 0);
    }
    public static string Screen() {
        var m = new DEVMODE(); m.Size = (ushort)Marshal.SizeOf(m);
        EnumDisplaySettingsW(null, -1, ref m);
        return m.PelsWidth + "x" + m.PelsHeight;
    }
    public static void Broadcast(uint message, string area) {
        IntPtr r; SendMessageTimeoutW((IntPtr)0xffff, message, IntPtr.Zero, area, 2, 5000, out r);
    }
    public static string Text(IntPtr h) { var s = new StringBuilder(512); GetWindowTextW(h, s, 512); return s.ToString(); }
    public static string Class(IntPtr h) { var s = new StringBuilder(256); GetClassNameW(h, s, 256); return s.ToString(); }
    // Visible top-level windows, front first.
    public static List<IntPtr> Visible() {
        var o = new List<IntPtr>();
        EnumWindows((h, l) => { if (IsWindowVisible(h)) o.Add(h); return true; }, IntPtr.Zero);
        return o;
    }
    // The frame as drawn, without the invisible resize borders.
    public static RECT Frame(IntPtr h) { RECT r; DwmGetWindowAttribute(h, 9, out r, Marshal.SizeOf(typeof(RECT))); return r; }
    // Alt down and up around the call, so Windows lets a background process take the focus.
    public static bool Focus(IntPtr h) {
        keybd_event(0x12, 0, 0, UIntPtr.Zero);
        bool ok = SetForegroundWindow(h);
        keybd_event(0x12, 0, 2, UIntPtr.Zero);
        return ok;
    }
}
'@
}
