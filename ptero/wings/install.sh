#!/bin/bash

# ==================================================
#  PTERODACTYL WINGS INSTALLER | Production UI
# ==================================================

# --- COLORS & STYLES ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[1;34m'
C_CYAN='\033[1;36m'
C_BG_RED='\033[41m'
C_BG_GREEN='\033[42m'

# --- VARIABLES ---
TOTAL_STEPS=6
CURRENT_STEP=1

# --- UI FUNCTIONS ---

# Hide cursor on start, show on exit
trap 'tput cnorm; echo -e "${C_RESET}"' EXIT
tput civis

header() {
    clear
    echo -e "${C_BLUE}"
    cat << "EOF"
    ██╗    ██╗██╗███╗   ██╗ ██████╗ ███████╗
    ██║    ██║██║████╗  ██║██╔════╝ ██╔════╝
    ██║ █╗ ██║██║██╔██╗ ██║██║  ███╗███████╗
    ██║███╗██║██║██║╚██╗██║██║   ██║╚════██║
    ╚███╔███╔╝██║██║ ╚████║╚██████╔╝███████║
     ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
EOF
    echo -e "    ${C_CYAN}PTERODACTYL WINGS AUTO-INSTALLER${C_RESET}"
    echo -e "${C_BLUE}──────────────────────────────────────────────────${C_RESET}"
    echo ""
}

print_step() {
    echo -e "${C_BLUE}[${CURRENT_STEP}/${TOTAL_STEPS}]${C_RESET} ${C_BOLD}$1${C_RESET}"
    ((CURRENT_STEP++))
}

print_status() {
    # $1 = Message, $2 = Command to run
    local msg="$1"
    local cmd="$2"
    local pid
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    echo -ne "  ${C_CYAN}➜${C_RESET} $msg... "
    
    # Run command in background, silence output
    eval "$cmd" > /dev/null 2>&1 &
    pid=$!
    
    # Spinner loop
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " ${C_BLUE}%c${C_RESET}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
        printf "\b\b"
    done
    wait $pid
    local exit_code=$?
    
    # Print Result Tag (Right Aligned)
    if [ $exit_code -eq 0 ]; then
        printf "\r\033[60C[ ${C_GREEN}OK${C_RESET} ]\n"
        # Reprint message to clean up spinner artifacts
        tput cuu1
        echo -e "  ${C_GREEN}✔${C_RESET} $msg"
    else
        printf "\r\033[60C[${C_RED}FAIL${C_RESET}]\n"
        echo -e "  ${C_RED}✖${C_RESET} $msg failed."
        echo -e "${C_YELLOW}Check logs for details.${C_RESET}"
        exit 1
    fi
}

# --- PRE-CHECKS ---
if [ "$EUID" -ne 0 ]; then
    echo -e "${C_RED}✖ Error:${C_RESET} Please run as root."
    exit 1
fi

header

# ------------------------
# 1. Docker Installation
# ------------------------
print_step "Container Engine Setup"
if ! command -v docker >/dev/null 2>&1; then
    print_status "Downloading Docker script" "curl -sSL https://get.docker.com/ -o /tmp/get-docker.sh"
    print_status "Installing Docker (This may take time)" "sh /tmp/get-docker.sh"
    print_status "Enabling Docker service" "systemctl enable --now docker"
else
    echo -e "  ${C_GREEN}✔${C_RESET} Docker is already installed"
fi
echo ""

# ------------------------
# 2. System Configuration
# ------------------------
print_step "System Configuration"
GRUB_FILE="/etc/default/grub"
if [ -f "$GRUB_FILE" ]; then
    # Only update if not already set
    if ! grep -q "swapaccount=1" "$GRUB_FILE"; then
        print_status "Enabling Swap Accounting (GRUB)" "sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"swapaccount=1\"/' $GRUB_FILE"
        print_status "Updating GRUB configuration" "update-grub"
    else
        echo -e "  ${C_GREEN}✔${C_RESET} Swap accounting already enabled"
    fi
else
    echo -e "  ${C_YELLOW}⚠${C_RESET} GRUB file not found, skipping..."
fi
echo ""

# ------------------------
# 3. Wings Binary
# ------------------------
print_step "Installing Wings"
print_status "Preparing directories" "mkdir -p /etc/pterodactyl"

ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then 
    ARCH="amd64"
else 
    ARCH="arm64"
fi
echo -e "  ${C_CYAN}➜${C_RESET} Architecture detected: ${C_BOLD}$ARCH${C_RESET}"

print_status "Downloading Wings binary" "curl -L -o /usr/local/bin/wings 'https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$ARCH'"
print_status "Setting executable permissions" "chmod u+x /usr/local/bin/wings"
echo ""

# ------------------------
# 4. Service Setup
# ------------------------
print_step "Service Configuration"
WINGS_SERVICE_FILE="/etc/systemd/system/wings.service"

# Create service file content
cat <<EOF > /tmp/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

print_status "Creating systemd service" "mv /tmp/wings.service $WINGS_SERVICE_FILE"
print_status "Reloading system daemon" "systemctl daemon-reload"
print_status "Enabling Wings on boot" "systemctl enable wings"
echo ""

# ------------------------
# 5. SSL Generation
# ------------------------
print_step "Security Configuration"
print_status "Creating certificate directory" "mkdir -p /etc/certs/wing"
print_status "Generating self-signed SSL" "openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj '/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate' -keyout /etc/certs/wing/privkey.pem -out /etc/certs/wing/fullchain.pem"
echo ""

# ------------------------
# 6. Helper Script
# ------------------------
print_step "Finalizing"
cat <<'EOF' > /usr/local/bin/wing
#!/bin/bash
BLUE='\033[0;34m'
NC='\033[0m'
echo -e "${BLUE}:: WINGS CONTROLLER ::${NC}"
echo "  start    : systemctl start wings"
echo "  stop     : systemctl stop wings"
echo "  restart  : systemctl restart wings"
echo "  logs     : journalctl -u wings -f"
echo "  status   : systemctl status wings"
echo ""
EOF

print_status "Installing 'wing' helper command" "chmod +x /usr/local/bin/wing"
echo ""

# ------------------------
# COMPLETE
# ------------------------
echo -e "${C_BLUE}──────────────────────────────────────────────────${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}   ✅  INSTALLATION COMPLETE${C_RESET}"
echo -e "${C_BLUE}──────────────────────────────────────────────────${C_RESET}"
echo ""
echo -e "   ${C_CYAN}To start Wings:${C_RESET}    sudo systemctl start wings"
echo -e "   ${C_CYAN}To view logs:${C_RESET}      sudo journalctl -u wings -f"
echo -e "   ${C_CYAN}Helper tool:${C_RESET}       Type ${C_BOLD}wing${C_RESET} in terminal"
echo ""
