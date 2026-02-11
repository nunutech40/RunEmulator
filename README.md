# 🚀 RunEmulator — Device Launcher

> **Launch Android Emulators & iOS Simulators from your terminal, no IDE needed!**

A lightweight, self-contained Bash script that automatically detects all available Android Virtual Devices (AVDs) and iOS Simulators, then lets you launch them interactively from the terminal. Perfect for developers who want to quickly spin up emulators/simulators without opening Android Studio or Xcode.

<p align="center">
  <br/>
  If you find this tool useful, consider supporting the development ☕
  <br/><br/>
  <a href="https://saweria.co/nunugraha17"><img src="https://img.shields.io/badge/Saweria-Support-orange?style=for-the-badge" alt="Saweria"></a>
  &nbsp;
  <a href="https://www.buymeacoffee.com/nunutech401"><img src="https://img.shields.io/badge/Buy_Me_A_Coffee-Support-yellow?style=for-the-badge&logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee"></a>
</p>

---

## ✨ Features

- 🔍 **Auto-detect** — Automatically discovers all Android AVDs and iOS Simulators
- 🤖 **Android Emulators** — Full support for Android Virtual Devices
- 🍎 **iOS Simulators** — Full support for iOS Simulators (macOS only, requires Xcode)
- 🖥️ **Cross-platform** — Works on both **macOS** and **Linux** out of the box
- 📱 **Interactive menu** — Clean, colorful terminal UI to select devices
- 🟢 **Running indicator** — Shows which devices are already running
- 🔄 **Multi-launch** — Launch multiple devices in one session
- 🚫 **Duplicate prevention** — Prevents launching the same device twice
- 🎨 **Pretty output** — Colored terminal output with emojis for a modern feel
- ⚡ **Zero dependencies** — Only requires Android SDK and/or Xcode (which you already have!)
- 📂 **Grouped by runtime** — iOS Simulators are organized by iOS version

---

## 📋 Prerequisites

### For Android Emulators
- **Android SDK** installed with at least one AVD configured
- At least one Android Virtual Device (AVD) created via Android Studio Device Manager

### For iOS Simulators (macOS only)
- **Xcode** installed with at least one simulator configured
- **Command Line Tools** installed (`xcode-select --install`)

### General
- **Bash** shell (version 3.2+)

> 💡 The script auto-detects available platforms. If you only have Android SDK, it shows only Android devices. If you only have Xcode, it shows only iOS simulators. If you have both — you get everything!

---

## 🖥️ Platform Compatibility

| Platform | Android Emulators | iOS Simulators | Notes |
|----------|:--:|:--:|-------|
| **macOS** | ✅ | ✅ | Double-click `RunEmu.command` or run `./run_emulator.sh` |
| **Linux** | ✅ | ❌ | Run `./run_emulator.sh` in terminal (no Xcode on Linux) |

---

## 🚀 Quick Start

### macOS

**Option 1: Double-click**
1. Open Finder and navigate to the project folder
2. Double-click `RunEmu.command`
3. Select a device from the menu — done!

**Option 2: Terminal**
```bash
chmod +x run_emulator.sh
./run_emulator.sh
```

### Linux

```bash
chmod +x run_emulator.sh
./run_emulator.sh
```

> 💡 If your Android SDK is in a custom location, set `ANDROID_HOME` first:
> ```bash
> export ANDROID_HOME="/path/to/your/android/sdk"
> ./run_emulator.sh
> ```

---

## 📖 Usage

```
╔═══════════════════════════════════════════════╗
║     🚀 Device Launcher                       ║
║     Android Emulators & iOS Simulators        ║
║     by Nunu Nugraha                           ║
╚═══════════════════════════════════════════════╝

🤖 Android Emulators (3 devices)
───────────────────────────────────────────────
  [1]  📲  Pixel 9 API 35
  [2]  📲  Pixel 7 Pro API 34               🟢 RUNNING
  [3]  📱  Medium Phone API 35

🍎 iOS Simulators (6 devices)
───────────────────────────────────────────────
  ▸ iOS 18.3
    [4]  📱  iPhone 16 Pro
    [5]  📱  iPhone 16 Pro Max
    [6]  📟  iPad Pro 11-inch (M4)
  ▸ iOS 17.2
    [7]  📱  iPhone 15 Pro
    [8]  📱  iPhone 15 Pro Max                🟢 RUNNING
    [9]  📟  iPad Air (5th generation)
───────────────────────────────────────────────
  [0]  ❌  Exit
───────────────────────────────────────────────

Pilih device [1-9]:
```

1. **Select a device** — Type the number and press Enter
2. **Wait for launch** — The device starts in the background
3. **Launch another** — Press Enter to go back to the menu, or `0` to exit

---

## 🔧 How It Works

### Android Emulators
1. Detects your OS (macOS/Linux) and locates the Android SDK automatically
2. Runs `emulator -list-avds` to discover all configured AVDs
3. Uses `adb devices` + `adb emu avd name` to detect running emulators
4. Launches the selected emulator via `emulator -avd <name>`

### iOS Simulators
1. Uses `xcrun simctl list devices available -j` to discover all available simulators
2. Parses the JSON output to get device names, UDIDs, states, and runtimes
3. Groups simulators by iOS runtime version for easy navigation
4. Boots the selected simulator via `xcrun simctl boot <udid>`
5. Opens the Simulator.app to display the UI

---

## 🤔 FAQ

### Will it auto-detect devices on another Mac?
**Yes!** The script dynamically discovers AVDs and simulators at runtime. It does **not** hardcode any device names. As long as the other Mac has Android SDK and/or Xcode installed with at least one device configured, it just works.

### Can I just share the single file?
**Yes!** The script is fully self-contained. You can share just `RunEmu.command` (or `run_emulator.sh`) — no other files needed. On macOS the `.command` file is double-clickable. On Linux, rename it or run it directly with `bash RunEmu.command`.

### Can I run multiple devices at the same time?
**Yes!** After launching one device, press Enter to return to the menu and launch another. Already-running devices are marked with 🟢 and can't be selected again.

### The script says "No Android SDK or Xcode found!"
Make sure at least one of these is installed:
- **Android SDK:** Auto-detected at `$HOME/Library/Android/sdk` (macOS) or `$HOME/Android/Sdk` (Linux)
- **Xcode:** Install from App Store, then run `xcode-select --install`

Or override Android SDK path with: `export ANDROID_HOME="/your/custom/path"`

### Can I use iOS Simulators on Linux?
**No.** iOS Simulators require Xcode, which is only available on macOS. On Linux, only Android Emulators are supported.

---

## 📁 Project Structure

```
RunEmulator/
├── run_emulator.sh      # Main script (for terminal use)
├── RunEmu.command        # macOS double-clickable launcher (same script)
├── LICENSE               # MIT License
└── README.md             # This file
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/nunutech40">Nunu Nugraha</a>
  <br/><br/>
  <a href="https://saweria.co/nunugraha17"><img src="https://img.shields.io/badge/Saweria-Support-orange?style=flat-square" alt="Saweria"></a>
  &nbsp;
  <a href="https://www.buymeacoffee.com/nunutech401"><img src="https://img.shields.io/badge/Buy_Me_A_Coffee-Support-yellow?style=flat-square&logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee"></a>
</p>
