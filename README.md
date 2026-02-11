# 🚀 RunEmulator — Android Emulator Launcher

> **Launch Android emulators from your terminal, no Android Studio needed!**

A lightweight, self-contained Bash script that automatically detects all available Android Virtual Devices (AVDs) and lets you launch them interactively from the terminal. Perfect for developers who want to quickly spin up emulators without opening Android Studio.

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

- 🔍 **Auto-detect** — Automatically discovers all AVDs configured on your machine
- �️ **Cross-platform** — Works on both **macOS** and **Linux** out of the box
- �📱 **Interactive menu** — Clean, colorful terminal UI to select emulators
- 🟢 **Running indicator** — Shows which emulators are already running
- 🔄 **Multi-launch** — Launch multiple emulators in one session
- 🚫 **Duplicate prevention** — Prevents launching the same emulator twice
- 🎨 **Pretty output** — Colored terminal output with emojis for a modern feel
- ⚡ **Zero dependencies** — Only requires Android SDK (which you already have!)

---

## 📋 Prerequisites

- **Android SDK** installed with at least one AVD configured
- **Bash** shell (version 3.2+)
- At least one Android Virtual Device (AVD) created via Android Studio Device Manager

> 💡 The script auto-detects your OS and uses the correct default SDK path. You can also override it by setting `ANDROID_HOME`.

---

## 🖥️ Platform Compatibility

| Platform | Status | Notes |
|----------|--------|-------|
| **macOS** | ✅ Supported | Double-click `RunEmu.command` or run `./run_emulator.sh` |
| **Linux** | ✅ Supported | Run `./run_emulator.sh` in terminal |

---

## 🚀 Quick Start

### macOS

**Option 1: Double-click**
1. Open Finder and navigate to the project folder
2. Double-click `RunEmu.command`
3. Select an emulator from the menu — done!

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
║     🚀 Android Emulator Launcher              ║
╚═══════════════════════════════════════════════╝

📱 Available Emulators:
───────────────────────────────────────────────
  [1]  📲  Pixel 9 API 35
  [2]  📲  Pixel 7 Pro API 34               🟢 RUNNING
  [3]  📱  Medium Phone API 35
───────────────────────────────────────────────
  [0]  ❌  Exit
───────────────────────────────────────────────

Pilih emulator [1-3]:
```

1. **Select an emulator** — Type the number and press Enter
2. **Wait for launch** — The emulator starts in the background
3. **Launch another** — Press Enter to go back to the menu, or `0` to exit

---

## 🔧 How It Works

1. Detects your OS (macOS/Linux) and locates the Android SDK automatically
2. Runs `emulator -list-avds` to discover all configured AVDs
3. Uses `adb devices` + `adb emu avd name` to detect running emulators
4. Displays an interactive menu with running status indicators
5. Launches the selected emulator in the background via `emulator -avd <name>`
6. Loops back to the menu for launching additional emulators

---

## 🤔 FAQ

### Will it auto-detect emulators on another laptop?
**Yes!** The script dynamically discovers AVDs at runtime using `emulator -list-avds`. It does **not** hardcode any emulator names. As long as the other laptop has Android SDK installed and at least one AVD created, it just works.

### Can I just share the single file?
**Yes!** The script is fully self-contained. You can share just `RunEmu.command` (or `run_emulator.sh`) — no other files needed. On macOS the `.command` file is double-clickable. On Linux, rename it or run it directly with `bash RunEmu.command`.

### Can I run multiple emulators at the same time?
**Yes!** After launching one emulator, press Enter to return to the menu and launch another. Already-running emulators are marked with 🟢 and can't be selected again.

### The script says "emulator not found"
Make sure your Android SDK is installed. The script checks these default paths:
- **macOS:** `$HOME/Library/Android/sdk`
- **Linux:** `$HOME/Android/Sdk`

Or override with: `export ANDROID_HOME="/your/custom/path"`

---

## 📁 Project Structure

```
RunEmulator/
├── run_emulator.sh     # Main script (for terminal use)
├── RunEmu.command       # macOS double-clickable launcher (same script)
└── README.md            # This file
```

---

## 📄 License

This project is open source. Feel free to use, modify, and distribute.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/nunutech40">Nunu Nugraha</a>
  <br/><br/>
  <a href="https://saweria.co/nunugraha17"><img src="https://img.shields.io/badge/Saweria-Support-orange?style=flat-square" alt="Saweria"></a>
  &nbsp;
  <a href="https://www.buymeacoffee.com/nunutech401"><img src="https://img.shields.io/badge/Buy_Me_A_Coffee-Support-yellow?style=flat-square&logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee"></a>
</p>
