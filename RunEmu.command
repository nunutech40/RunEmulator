#!/bin/bash

# ============================================
#  🚀 Device Launcher
#  Detect & run Android Emulators and
#  iOS Simulators from terminal
#  Self-contained — no external scripts needed
# ============================================

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ── Android SDK path — auto-detect OS ──
if [ -z "$ANDROID_HOME" ]; then
    case "$(uname -s)" in
        Darwin) ANDROID_SDK="$HOME/Library/Android/sdk" ;;
        Linux)  ANDROID_SDK="$HOME/Android/Sdk" ;;
        *)      ANDROID_SDK="$HOME/Android/Sdk" ;;
    esac
else
    ANDROID_SDK="$ANDROID_HOME"
fi
EMULATOR_BIN="$ANDROID_SDK/emulator/emulator"
ADB_BIN="$ANDROID_SDK/platform-tools/adb"

# ── Detect platform capabilities ──
HAS_ANDROID=false
HAS_IOS=false

if [ -f "$EMULATOR_BIN" ]; then
    HAS_ANDROID=true
fi

if command -v xcrun &>/dev/null && xcrun simctl list devices &>/dev/null 2>&1; then
    HAS_IOS=true
fi

# Exit if neither platform is available
if [ "$HAS_ANDROID" = false ] && [ "$HAS_IOS" = false ]; then
    echo -e "${RED}❌ Error: No Android SDK or Xcode found!${NC}"
    echo -e "${DIM}   Install Android Studio and/or Xcode to use this tool.${NC}"
    echo ""
    echo "Press any key to exit..."
    read -n 1 -s
    exit 1
fi

# ── Function to get list of running Android emulator AVD names ──
get_running_android_emulators() {
    RUNNING_ANDROID=()
    if [ "$HAS_ANDROID" = true ] && [ -f "$ADB_BIN" ]; then
        local serials=()
        while IFS= read -r line; do
            if echo "$line" | grep -q "^emulator-"; then
                local serial=$(echo "$line" | awk '{print $1}')
                serials+=("$serial")
            fi
        done < <("$ADB_BIN" devices 2>/dev/null)

        for serial in "${serials[@]}"; do
            local avd_name
            avd_name=$("$ADB_BIN" -s "$serial" emu avd name 2>/dev/null | head -1 | tr -d '\r')
            if [ -n "$avd_name" ]; then
                RUNNING_ANDROID+=("$avd_name")
            fi
        done
    fi
}

# ── Function to check if an Android emulator is running ──
is_android_running() {
    local avd_name="$1"
    for running in "${RUNNING_ANDROID[@]}"; do
        if [ "$running" = "$avd_name" ]; then
            return 0
        fi
    done
    return 1
}

# ── Function to get iOS simulators ──
# Populates parallel arrays: IOS_NAMES, IOS_UDIDS, IOS_STATES, IOS_RUNTIMES
get_ios_simulators() {
    IOS_NAMES=()
    IOS_UDIDS=()
    IOS_STATES=()
    IOS_RUNTIMES=()

    if [ "$HAS_IOS" = false ]; then
        return
    fi

    # Use python3 to parse JSON (available on macOS by default)
    while IFS='|' read -r runtime name udid state; do
        # Trim whitespace
        runtime=$(echo "$runtime" | xargs)
        name=$(echo "$name" | xargs)
        udid=$(echo "$udid" | xargs)
        state=$(echo "$state" | xargs)

        IOS_NAMES+=("$name")
        IOS_UDIDS+=("$udid")
        IOS_STATES+=("$state")
        IOS_RUNTIMES+=("$runtime")
    done < <(xcrun simctl list devices available -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in sorted(data['devices'].items()):
    rt_name = runtime.replace('com.apple.CoreSimulator.SimRuntime.', '').replace('-', '.').replace('.', ' ', 1).replace(' ', '-', 1)
    for d in devices:
        print(f'{rt_name}|{d[\"name\"]}|{d[\"udid\"]}|{d[\"state\"]}')
" 2>/dev/null)
}

# ── Function to show the footer / credits ──
show_footer() {
    echo -e ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${BOLD}  👤 Nunu Nugraha                              ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}🐙 GitHub${NC}    ${DIM}→${NC} ${CYAN}github.com/nunutech40${NC}        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}☕ Saweria${NC}   ${DIM}→${NC} ${CYAN}saweria.co/nunugraha17${NC}       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}☕ BMC${NC}       ${DIM}→${NC} ${CYAN}buymeacoffee.com/nunutech401${NC} ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo -e ""
    echo -e "${DIM}👋 Bye!${NC}"
}

# ── Main loop ──
while true; do
    # Clear screen
    clear

    # Header
    echo -e ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${BOLD}     🚀 Device Launcher                       ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${DIM}     Android Emulators & iOS Simulators        ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${DIM}     by Nunu Nugraha                          ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo -e ""

    # ── Detect devices ──
    echo -e "${DIM}Detecting devices...${NC}"

    # === ANDROID EMULATORS ===
    ANDROID_EMULATORS=()
    if [ "$HAS_ANDROID" = true ]; then
        while IFS= read -r line; do
            [ -n "$line" ] && ANDROID_EMULATORS+=("$line")
        done < <("$EMULATOR_BIN" -list-avds 2>/dev/null)
    fi

    get_running_android_emulators

    # === iOS SIMULATORS ===
    get_ios_simulators

    # Build unified device list
    # Types: "android" or "ios"
    # For each device we store: TYPE, NAME, DISPLAY_NAME, ID (avd name or udid), RUNNING (true/false), RUNTIME (for iOS)
    ALL_TYPES=()
    ALL_NAMES=()
    ALL_DISPLAY=()
    ALL_IDS=()
    ALL_RUNNING=()
    ALL_RUNTIMES=()

    # Add Android devices
    for emu in "${ANDROID_EMULATORS[@]}"; do
        display_name=$(echo "$emu" | sed 's/_/ /g' | sed 's/ - / — /g')
        is_running="false"
        if is_android_running "$emu"; then
            is_running="true"
        fi
        ALL_TYPES+=("android")
        ALL_NAMES+=("$emu")
        ALL_DISPLAY+=("$display_name")
        ALL_IDS+=("$emu")
        ALL_RUNNING+=("$is_running")
        ALL_RUNTIMES+=("-")
    done

    # Add iOS devices
    for i in "${!IOS_NAMES[@]}"; do
        is_running="false"
        if [ "${IOS_STATES[$i]}" = "Booted" ]; then
            is_running="true"
        fi
        ALL_TYPES+=("ios")
        ALL_NAMES+=("${IOS_NAMES[$i]}")
        ALL_DISPLAY+=("${IOS_NAMES[$i]}")
        ALL_IDS+=("${IOS_UDIDS[$i]}")
        ALL_RUNNING+=("$is_running")
        ALL_RUNTIMES+=("${IOS_RUNTIMES[$i]}")
    done

    total=${#ALL_TYPES[@]}

    # Check if any devices found
    if [ "$total" -eq 0 ]; then
        echo -e "${RED}❌ No devices found!${NC}"
        echo -e "${DIM}   Create emulators in Android Studio → Device Manager${NC}"
        echo -e "${DIM}   Create simulators in Xcode → Window → Devices and Simulators${NC}"
        echo ""
        echo "Press any key to exit..."
        read -n 1 -s
        exit 1
    fi

    echo -e ""

    # ── Display Android Emulators ──
    android_count=${#ANDROID_EMULATORS[@]}
    running_android_count=${#RUNNING_ANDROID[@]}
    available_count=0
    num=0

    if [ "$android_count" -gt 0 ]; then
        echo -e "${GREEN}${BOLD}🤖 Android Emulators${NC} ${DIM}($android_count devices)${NC}"
        echo -e "${DIM}───────────────────────────────────────────────${NC}"

        for i in "${!ANDROID_EMULATORS[@]}"; do
            num=$((num + 1))
            display_name=$(echo "${ANDROID_EMULATORS[$i]}" | sed 's/_/ /g' | sed 's/ - / — /g')

            # Icon
            if echo "${ANDROID_EMULATORS[$i]}" | grep -qi "tablet"; then
                icon="📱"
            elif echo "${ANDROID_EMULATORS[$i]}" | grep -qi "pixel"; then
                icon="📲"
            else
                icon="📱"
            fi

            if is_android_running "${ANDROID_EMULATORS[$i]}"; then
                echo -e "  ${DIM}${BOLD}[$num]${NC}  ${icon}  ${DIM}${display_name}  ${GREEN}🟢 RUNNING${NC}"
                echo -e "       ${DIM}${ANDROID_EMULATORS[$i]}${NC}"
            else
                echo -e "  ${GREEN}${BOLD}[$num]${NC}  ${icon}  ${BOLD}${display_name}${NC}"
                echo -e "       ${DIM}${ANDROID_EMULATORS[$i]}${NC}"
                available_count=$((available_count + 1))
            fi
        done
        echo -e ""
    elif [ "$HAS_ANDROID" = true ]; then
        echo -e "${DIM}🤖 Android Emulators: none found${NC}"
        echo -e ""
    fi

    # ── Display iOS Simulators (grouped by runtime) ──
    ios_count=${#IOS_NAMES[@]}
    ios_booted=0

    if [ "$ios_count" -gt 0 ]; then
        # Count booted
        for state in "${IOS_STATES[@]}"; do
            if [ "$state" = "Booted" ]; then
                ios_booted=$((ios_booted + 1))
            fi
        done

        echo -e "${BLUE}${BOLD}🍎 iOS Simulators${NC} ${DIM}($ios_count devices)${NC}"
        echo -e "${DIM}───────────────────────────────────────────────${NC}"

        current_runtime=""
        for i in "${!IOS_NAMES[@]}"; do
            num=$((num + 1))

            # Print runtime header if changed
            if [ "${IOS_RUNTIMES[$i]}" != "$current_runtime" ]; then
                current_runtime="${IOS_RUNTIMES[$i]}"
                runtime_display=$(echo "$current_runtime" | sed 's/\./ /g')
                echo -e "  ${MAGENTA}${BOLD}▸ ${runtime_display}${NC}"
            fi

            # Icon based on device type
            if echo "${IOS_NAMES[$i]}" | grep -qi "ipad"; then
                icon="📟"
            elif echo "${IOS_NAMES[$i]}" | grep -qi "iphone"; then
                icon="📱"
            else
                icon="📱"
            fi

            if [ "${IOS_STATES[$i]}" = "Booted" ]; then
                echo -e "    ${DIM}${BOLD}[$num]${NC}  ${icon}  ${DIM}${IOS_NAMES[$i]}  ${GREEN}🟢 RUNNING${NC}"
                echo -e "         ${DIM}${IOS_UDIDS[$i]}${NC}"
            else
                echo -e "    ${BLUE}${BOLD}[$num]${NC}  ${icon}  ${BOLD}${IOS_NAMES[$i]}${NC}"
                echo -e "         ${DIM}${IOS_UDIDS[$i]}${NC}"
                available_count=$((available_count + 1))
            fi
        done
        echo -e ""
    elif [ "$HAS_IOS" = true ]; then
        echo -e "${DIM}🍎 iOS Simulators: none found${NC}"
        echo -e ""
    fi

    echo -e "${DIM}───────────────────────────────────────────────${NC}"
    echo -e "  ${RED}${BOLD}[0]${NC}  ❌  Exit"
    echo -e "${DIM}───────────────────────────────────────────────${NC}"

    # Show running count info
    total_running=$((running_android_count + ios_booted))
    if [ "$total_running" -gt 0 ]; then
        echo -e ""
        echo -e "  ${GREEN}🟢 $total_running device sedang berjalan${NC}"
    fi

    echo -e ""

    # Check if all devices are running
    if [ "$available_count" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Semua device sudah berjalan!${NC}"
        echo -e ""
        echo -ne "${CYAN}${BOLD}Tekan 0 untuk exit, atau Enter untuk refresh: ${NC}"
        read -r choice
        if [ "$choice" = "0" ]; then
            show_footer
            exit 0
        fi
        continue
    fi

    # ── Get user selection ──
    while true; do
        echo -ne "${CYAN}${BOLD}Pilih device [1-${num}]: ${NC}"
        read -r choice

        # Exit option
        if [ "$choice" = "0" ]; then
            show_footer
            exit 0
        fi

        # Validate input
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$num" ]; then
            selected_index=$((choice - 1))

            selected_type="${ALL_TYPES[$selected_index]}"
            selected_name="${ALL_NAMES[$selected_index]}"
            selected_display="${ALL_DISPLAY[$selected_index]}"
            selected_id="${ALL_IDS[$selected_index]}"
            selected_running="${ALL_RUNNING[$selected_index]}"
            selected_runtime="${ALL_RUNTIMES[$selected_index]}"

            # Check if already running
            if [ "$selected_running" = "true" ]; then
                echo -e "${YELLOW}⚠️  Device ini sudah berjalan! Pilih yang lain.${NC}"
            else
                break
            fi
        else
            echo -e "${RED}⚠️  Input tidak valid. Masukkan angka 1-${num} (atau 0 untuk exit)${NC}"
        fi
    done

    echo -e ""

    # ── Launch the selected device ──
    if [ "$selected_type" = "android" ]; then
        echo -e "${GREEN}🚀 Starting Android Emulator: ${BOLD}${selected_display}${NC}"
        echo -e "${DIM}   AVD: ${selected_name}${NC}"
        echo -e "${DIM}   Please wait, this might take a moment...${NC}"
        echo -e ""

        "$EMULATOR_BIN" -avd "$selected_name" &>/dev/null &
        DEVICE_PID=$!

        echo -e "${GREEN}✅ Emulator launched! ${DIM}(PID: $DEVICE_PID)${NC}"

    elif [ "$selected_type" = "ios" ]; then
        runtime_display=$(echo "$selected_runtime" | sed 's/\./ /g')
        echo -e "${BLUE}🚀 Starting iOS Simulator: ${BOLD}${selected_display}${NC}"
        echo -e "${DIM}   UDID: ${selected_id}${NC}"
        echo -e "${DIM}   Runtime: ${runtime_display}${NC}"
        echo -e "${DIM}   Please wait, this might take a moment...${NC}"
        echo -e ""

        # Boot the simulator
        xcrun simctl boot "$selected_id" 2>/dev/null

        # Open Simulator.app to show the UI
        open -a Simulator 2>/dev/null

        echo -e "${GREEN}✅ Simulator launched!${NC}"
    fi

    echo -e ""
    echo -e "${DIM}───────────────────────────────────────────────${NC}"
    echo -e "${CYAN}${BOLD}  Mau jalanin device lain?${NC}"
    echo -e "${DIM}  Tekan Enter untuk kembali ke menu, atau 0 untuk exit.${NC}"
    echo -e "${DIM}───────────────────────────────────────────────${NC}"
    echo -ne "${CYAN}${BOLD}  > ${NC}"
    read -r next_action

    if [ "$next_action" = "0" ]; then
        show_footer
        echo -e "${DIM}Device tetap berjalan.${NC}"
        exit 0
    fi

    # Loop kembali ke menu
done
