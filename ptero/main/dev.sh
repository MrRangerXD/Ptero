#!/bin/bash
# ===========================================================
# CODING HUB Terminal Control Panel (v2.1 - New Banner)
# Mode By - Nobita
# ===========================================================

# --- COLORS & STYLES ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color
GRAY='\033[38;5;240m'
ORANGE='\033[38;5;208m'

# --- UI ELEMENTS (Adjusted Width for New Banner) ---
# Width set to match the large banner (approx 98 chars)
T_LINE="${GRAY}──────────────────────────────────────────────────────────────────────────────────────────────────${NC}"
T_TOP="${GRAY}┌──────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
T_BOT="${GRAY}└──────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"
T_SIDE="${GRAY}│${NC}"

# ===================== HELPER FUNCTIONS =====================

pause(){ 
    echo -e "\n${GRAY}  Press [ENTER] to continue...${NC}"
    read -r
}

loading_bar() {
    echo -ne "${CYAN}  Loading: ${NC}[ "
    for i in {1..20}; do
        echo -ne "${GREEN}▓${NC}"
        sleep 0.02
    done
    echo -e " ] ${GREEN}Done!${NC}"
    sleep 0.3
}

# ===================== HEADER & BANNER =====================
header(){
    clear
    # Dynamic Random Color for Logo
    COLORS=($RED $GREEN $YELLOW $BLUE $PURPLE $CYAN)
    RC=${COLORS[$RANDOM % ${#COLORS[@]}]}
    
    echo -e "${RC}"
    echo " ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗     ██╗  ██╗██╗   ██╗██████╗ "
    echo "██╔════╝██╔═══██╗██╔══██╗██║████╗  ██║██╔════╝     ██║  ██║██║   ██║██╔══██╗"
    echo "██║     ██║   ██║██║  ██║██║██╔██╗ ██║██║  ███╗    ███████║██║   ██║██████╔╝"
    echo "██║     ██║   ██║██║  ██║██║██║╚██╗██║██║   ██║    ██╔══██║██║   ██║██╔══██╗"
    echo "╚██████╗╚██████╔╝██████╔╝██║██║ ╚████║╚██████╔╝    ██║  ██║╚██████╔╝██████╔╝"
    echo " ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ "
    echo -e "${NC}"
    
    echo -e "                               ${BOLD}>> DEVELOPED BY NOBITA (2026) <<${NC}"
    echo -e ""
    # System Status Bar
    USER_INFO=$(whoami)
    HOST_INFO=$(hostname)
    DATE_INFO=$(date +'%H:%M')
    echo -e "  ${GRAY}User:${NC} $USER_INFO ${GRAY}|${NC} ${GRAY}Host:${NC} $HOST_INFO ${GRAY}|${NC} ${GRAY}Time:${NC} $DATE_INFO"
    echo -e "${T_LINE}"
}

# ===================== MAIN MENU =====================
main_menu(){
    # Initial Loading Effect
    clear
    echo -e "${CYAN}Starting Coding Hub Panel...${NC}"
    sleep 1
    loading_bar

    while true; do 
        header
        echo -e "  ${GREEN}:: MAIN MENU ::${NC}"
        echo -e "${T_TOP}"
        # Adjusted alignment to fit new width
        printf "${T_SIDE}  ${WHITE}[01]${NC} %-40s ${WHITE}[05]${NC} %-40s ${T_SIDE}\n" "VPS Run Setup" "Theme Manager"
        printf "${T_SIDE}  ${WHITE}[02]${NC} %-40s ${WHITE}[06]${NC} %-40s ${T_SIDE}\n" "Panel Manager" "System Options"
        printf "${T_SIDE}  ${WHITE}[03]${NC} %-40s ${WHITE}[07]${NC} %-40s ${T_SIDE}\n" "Wings Installation" "External Infra"
        printf "${T_SIDE}  ${WHITE}[04]${NC} %-40s ${RED}[08]${NC} %-40s ${T_SIDE}\n" "Tools Utility" "Exit Panel"
        echo -e "${T_BOT}"
        
        echo -e "${GRAY}  Enter the number corresponding to your choice:${NC}"
        echo -ne "  ${BOLD}${GREEN}root@codinghub:~#${NC} "
        read -p "" c

        case $c in
            1) loading_bar; bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/vm/vps.sh) ;;
            2) loading_bar; panel_menu ;;
            3) loading_bar; bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/wings/www.sh) ;;
            4) loading_bar; tools_menu ;;
            5) loading_bar; theme_menu ;;
            6) loading_bar; bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/menu/System1.sh) ;;
            7) bash <(curl -s https://raw.githubusercontent.com/nobita329/The-Coding-Hub/refs/heads/main/srv/External/INFRA.sh) ;;
            8) 
                echo -e ""
                echo -e "  ${GREEN}Thank you for using CODING HUB!${NC}"
                echo -e "  ${GRAY}See you soon, Nobita.${NC}"
                echo -e ""
                exit 
                ;;
            *) echo -e "  ${RED}Invalid Selection. Try again.${NC}"; sleep 1 ;;
        esac
    done
}

# Start the script
main_menu
