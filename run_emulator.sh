#!/bin/bash

# ============================================
#  🚀 Android Emulator Launcher
#  Detect & run Android emulators from terminal
#  Self-contained — no external scripts needed
# ============================================

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Android SDK path — auto-detect OS
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

# Check if emulator binary exists
if [ ! -f "$EMULATOR_BIN" ]; then
    echo -e "${RED}❌ Error: Android emulator not found at $EMULATOR_BIN${NC}"
    echo -e "${DIM}   Make sure ANDROID_HOME is set correctly.${NC}"
    echo ""
    echo "Press any key to exit..."
    read -n 1 -s
    exit 1
fi

# Function to get list of running emulator AVD names
get_running_emulators() {
    RUNNING_EMULATORS=()
    if [ -f "$ADB_BIN" ]; then
        # Get list of running emulator serial numbers
        local serials=()
        while IFS= read -r line; do
            if echo "$line" | grep -q "^emulator-"; then
                local serial=$(echo "$line" | awk '{print $1}')
                serials+=("$serial")
            fi
        done < <("$ADB_BIN" devices 2>/dev/null)

        # For each running emulator, get its AVD name
        for serial in "${serials[@]}"; do
            local avd_name
            avd_name=$("$ADB_BIN" -s "$serial" emu avd name 2>/dev/null | head -1 | tr -d '\r')
            if [ -n "$avd_name" ]; then
                RUNNING_EMULATORS+=("$avd_name")
            fi
        done
    fi
}

# Function to check if an emulator is running
is_running() {
    local avd_name="$1"
    for running in "${RUNNING_EMULATORS[@]}"; do
        if [ "$running" = "$avd_name" ]; then
            return 0
        fi
    done
    return 1
}

# Main loop
while true; do
    # Clear screen
    clear

    # Header
    echo -e ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${BOLD}     🚀 Android Emulator Launcher              ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${DIM}     by Nunu Nugraha                          ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo -e ""

    # Detect available emulators
    echo -e "${DIM}Detecting emulators...${NC}"

    # Read emulators into an array
    EMULATORS=()
    while IFS= read -r line; do
        [ -n "$line" ] && EMULATORS+=("$line")
    done < <("$EMULATOR_BIN" -list-avds 2>/dev/null)

    # Check if any emulators found
    if [ ${#EMULATORS[@]} -eq 0 ]; then
        echo -e "${RED}❌ No emulators found!${NC}"
        echo -e "${DIM}   Create one in Android Studio → Device Manager${NC}"
        echo ""
        echo "Press any key to exit..."
        read -n 1 -s
        exit 1
    fi

    # Get running emulators
    get_running_emulators
    running_count=${#RUNNING_EMULATORS[@]}

    echo -e ""

    # Display available emulators
    echo -e "${YELLOW}📱 Available Emulators:${NC}"
    echo -e "${DIM}───────────────────────────────────────────────${NC}"

    available_count=0
    for i in "${!EMULATORS[@]}"; do
        num=$((i + 1))
        # Make the name more readable
        display_name=$(echo "${EMULATORS[$i]}" | sed 's/_/ /g' | sed 's/ - / — /g')

        # Different emoji per device type
        if echo "${EMULATORS[$i]}" | grep -qi "tablet"; then
            icon="📱"
        elif echo "${EMULATORS[$i]}" | grep -qi "pixel"; then
            icon="📲"
        else
            icon="📱"
        fi

        # Check if this emulator is already running
        if is_running "${EMULATORS[$i]}"; then
            echo -e "  ${DIM}${BOLD}[$num]${NC}  ${icon}  ${DIM}${display_name}  ${GREEN}🟢 RUNNING${NC}"
            echo -e "       ${DIM}${EMULATORS[$i]}${NC}"
        else
            echo -e "  ${GREEN}${BOLD}[$num]${NC}  ${icon}  ${BOLD}${display_name}${NC}"
            echo -e "       ${DIM}${EMULATORS[$i]}${NC}"
            available_count=$((available_count + 1))
        fi
    done

    echo -e "${DIM}───────────────────────────────────────────────${NC}"
    echo -e "  ${RED}${BOLD}[0]${NC}  ❌  Exit"
    echo -e "${DIM}───────────────────────────────────────────────${NC}"

    # Show running count info
    if [ "$running_count" -gt 0 ]; then
        echo -e ""
        echo -e "  ${GREEN}🟢 $running_count emulator sedang berjalan${NC}"
    fi

    echo -e ""

    # Check if all emulators are running
    if [ "$available_count" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Semua emulator sudah berjalan!${NC}"
        echo -e ""
        echo -ne "${CYAN}${BOLD}Tekan 0 untuk exit, atau Enter untuk refresh: ${NC}"
        read -r choice
        if [ "$choice" = "0" ]; then
            echo -e ""
            echo -e "${DIM}───────────────────────────────────────────────${NC}"
            echo -e "${DIM}  oleh ${NC}${BOLD}Nunu Nugraha${NC}"
            echo -e "${DIM}  Support:${NC}"
            echo -e "  ${YELLOW}☕ Saweria${NC}   ${DIM}→${NC} ${CYAN}https://saweria.co/nunugraha17${NC}"
            echo -e "  ${YELLOW}☕ BMC${NC}       ${DIM}→${NC} ${CYAN}https://www.buymeacoffee.com/nunutech401${NC}"
            echo -e "${DIM}───────────────────────────────────────────────${NC}"
            echo -e ""
            echo -e "${DIM}👋 Bye!${NC}"
            exit 0
        fi
        continue
    fi

    # Get user selection
    while true; do
        echo -ne "${CYAN}${BOLD}Pilih emulator [1-${#EMULATORS[@]}]: ${NC}"
        read -r choice

        # Exit option
        if [ "$choice" = "0" ]; then
            echo -e ""
            echo -e "${DIM}───────────────────────────────────────────────${NC}"
            echo -e "${DIM}  oleh ${NC}${BOLD}Nunu Nugraha${NC}"
            echo -e "${DIM}  Support:${NC}"
            echo -e "  ${YELLOW}☕ Saweria${NC}   ${DIM}→${NC} ${CYAN}https://saweria.co/nunugraha17${NC}"
            echo -e "  ${YELLOW}☕ BMC${NC}       ${DIM}→${NC} ${CYAN}https://www.buymeacoffee.com/nunutech401${NC}"
            echo -e "${DIM}───────────────────────────────────────────────${NC}"
            echo -e ""
            echo -e "${DIM}👋 Bye!${NC}"
            exit 0
        fi

        # Validate input
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#EMULATORS[@]}" ]; then
            selected_index=$((choice - 1))
            selected="${EMULATORS[$selected_index]}"

            # Check if already running
            if is_running "$selected"; then
                echo -e "${YELLOW}⚠️  Emulator ini sudah berjalan! Pilih yang lain.${NC}"
            else
                break
            fi
        else
            echo -e "${RED}⚠️  Input tidak valid. Masukkan angka 1-${#EMULATORS[@]} (atau 0 untuk exit)${NC}"
        fi
    done

    # Get selected emulator
    display_name=$(echo "$selected" | sed 's/_/ /g' | sed 's/ - / — /g')

    echo -e ""
    echo -e "${GREEN}🚀 Starting: ${BOLD}${display_name}${NC}"
    echo -e "${DIM}   AVD: ${selected}${NC}"
    echo -e "${DIM}   Please wait, this might take a moment...${NC}"
    echo -e ""

    # Run the emulator in the background
    "$EMULATOR_BIN" -avd "$selected" &>/dev/null &
    EMULATOR_PID=$!

    echo -e "${GREEN}✅ Emulator launched! ${DIM}(PID: $EMULATOR_PID)${NC}"
    echo -e ""
    echo -e "${DIM}───────────────────────────────────────────────${NC}"
    echo -e "${CYAN}${BOLD}  Mau jalanin emulator lain?${NC}"
    echo -e "${DIM}  Tekan Enter untuk kembali ke menu, atau 0 untuk exit.${NC}"
    echo -e "${DIM}───────────────────────────────────────────────${NC}"
    echo -ne "${CYAN}${BOLD}  > ${NC}"
    read -r next_action

    if [ "$next_action" = "0" ]; then
        echo -e ""
        echo -e "${DIM}───────────────────────────────────────────────${NC}"
        echo -e "${DIM}  oleh ${NC}${BOLD}Nunu Nugraha${NC}"
        echo -e "${DIM}  Support:${NC}"
        echo -e "  ${YELLOW}☕ Saweria${NC}   ${DIM}→${NC} ${CYAN}https://saweria.co/nunugraha17${NC}"
        echo -e "  ${YELLOW}☕ BMC${NC}       ${DIM}→${NC} ${CYAN}https://www.buymeacoffee.com/nunutech401${NC}"
        echo -e "${DIM}───────────────────────────────────────────────${NC}"
        echo -e ""
        echo -e "${DIM}👋 Bye! Emulator tetap berjalan.${NC}"
        exit 0
    fi

    # Loop kembali ke menu
done
