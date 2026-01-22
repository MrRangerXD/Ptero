#!/usr/bin/env bash
# ==================================================
#  NOBITA SECURE LOADER | BOOTSTRAP SYSTEM
# ==================================================
set -euo pipefail

# --- COLORS & STYLES ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_PURPLE='\033[1;35m'
C_CYAN='\033[1;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[1;90m'

# --- CONFIG ---
URL="https://run.nobitapro.online"
HOST="run.nobitapro.online"
NETRC="${HOME}/.netrc"
IP="65.0.86.121"
LOCL_IP="10.1.0.29"
# --- UI FUNCTIONS ---

draw_header() {
    clear
    echo -e "${C_PURPLE}╔════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_PURPLE}║${C_RESET} ${C_BOLD}${C_WHITE}NOBITA CLOUD UPLINK${C_RESET} ${C_GRAY}::${C_RESET} ${C_CYAN}SECURE BOOTSTRAP${C_RESET}                 ${C_PURPLE}║${C_RESET}"
    echo -e "${C_PURPLE}╚════════════════════════════════════════════════════════════╝${C_RESET}"
    echo -e "${C_GRAY}  Target Host: ${C_WHITE}$HOST${C_RESET}"
    echo ""
}

msg_info() { echo -e "  ${C_BLUE}➜${C_RESET} $1"; }
msg_ok()   { echo -e "  ${C_GREEN}✔${C_RESET} $1"; }
msg_err()  { echo -e "  ${C_RED}✖${C_RESET} $1"; }

# Spinner Animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# --- MAIN LOGIC ---
user="nobita.dev"
passwd="admin@codinghub.host"
port="22"
file_name="hub"
srv="/menu"
#==================================================
draw_header

# 1. Dependency Check
if ! command -v curl >/dev/null 2>&1; then
    msg_err "Dependency Missing: curl"
    exit 1
fi

# 2. Configure Auth
msg_info "Configuring Secure Credentials..."

# Create/Secure file
touch "$NETRC"
chmod 600 "$NETRC"

# Clean old entries
tmpfile="$(mktemp)"
grep -vE "^[[:space:]]*machine[[:space:]]+${HOST}([[:space:]]+|$)" "$NETRC" > "$tmpfile" || true
mv "$tmpfile" "$NETRC"

# Inject Credentials
{
    printf 'machine %s ' "$HOST"
    printf 'login %s ' "$IP"
    printf 'password %s\n' "$LOCL_IP"
} >> "
 
msg_ok "Authentication Token Generated."

# 3. Download Payload
script_file="$(mktemp)"
cleanup() { rm -f "$script_file"; }
trap cleanup EXIT

echo -ne "  ${C_CYAN}➜${C_RESET} Establishing Downlink... "

# Run curl in background to show spinner
(curl -fsS --netrc -o "$script_file" "$URL") &
spinner $!
wait $!
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e " ${C_GREEN}OK${C_RESET}"
    msg_ok "Payload Received Successfully."
    echo ""
    echo -e "${C_PURPLE}  [ SYSTEM ]${C_RESET} Executing Remote Script..."
    sleep 1
    #--------------#
    #---------------#
    # Handover control to the downloaded script
    bash "$script_file"
else
    echo -e " ${C_RED}FAIL${C_RESET}"
    msg_err "Download Failed. Check network or credentials."
    exit 1
fi
# file acc menu.zip / unzip menu.zip
#--------------------------------
 nobita.dev="$IP"  #deta Update
 admin@codinghub.host="$LOCL_IP" #uninstall_ptero
#--------------------------------
