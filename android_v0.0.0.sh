#!/data/data/com.termux/files/usr/bin/bash

# Variables for text formatting
  BOLD='\033[1m'
  UNDERLINE='\033[4m'
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  CLEAR_COLOR='\033[0;0m'

# Function for displaying script header
print_header() {
  clear
  printf "               ${BOLD}${UNDERLINE}COMMAND LINE TOOLKIT FOR EASY DERO USAGE${CLEAR_COLOR}
  ${MAGENTA}${BOLD}<================================================================>
       ${RED}(         (       )      *    (       ) (       ) 
       /\ )      )\ ) ( /(    (     )\ ) ( /( )\ ) ( /( (      
      (()/(  (  (()/( )\())   )\))( (()/( )\()|()/( )\()))\ )   
      /(_)) )\  /(_)|(_)\   ((_)()\ /(_)|(_)\ /(_)|(_)\(()/(   
      (_))_ ((_)(_))  ((_)  (_()((_|_))  _((_|_))  _((_)/(_))_${CLEAR_COLOR}   
      ${BOLD}|   \| __| _ \ / _ \  |  \/  |_ _|| \| |_ _|| \| (_)) __|
      | |) | _||   /| (_) | | |\/| || | | .  || | | .  | | (_ |
      ${UNDERLINE}|___/|___|_|_\ \___/${CLEAR_COLOR}  ${UNDERLINE}|_|  |_|___||_|\_|___||_|\_|__\___|${CLEAR_COLOR}                                                                                                                                                                                                                                                                                                         
              Incentivize features here: ${GREEN}${BOLD}${UNDERLINE}derocious${CLEAR_COLOR}
        ${BOLD}${UNDERLINE}INCLUDE DESIRED FEATURE IN THE COMMENT OF TRANSACTION${CLEAR_COLOR} 
 ${MAGENTA}${BOLD} <================================================================>${CLEAR_COLOR}"                                                                                                        
}

# Environment variables
  BASE_ADDRESS='mysrv.cloud'
  NODE_ADDRESS='dero-node.'
  POOL_ADDRESS='community-pools.'
  POOL_PORT=10300
  SOLO_PORT=10100
  RPC_PORT=10102
  PACKAGE_MANAGER="pkg"
  CPU_THREADS=$(nproc)
  LOG_FILE="script_status.log"
  FASTREG_REPO="https://github.com/deroholic/fastreg.git"
  OS_TYPE="linux"


# Function to log messages to both stdout and a log file
log_message() {
  local MESSAGE=$1
  printf "${MESSAGE}"
  echo " "
  echo "$(date +'%Y-%m-%d %H:%M:%S'): ${MESSAGE}" >> "$LOG_FILE"
  echo " "
}

# Function to determine CPU type and system architecture
set_platform() {
  SYSTEM_ARCH=$(uname -m)
  if [[ $SYSTEM_ARCH == "x86_64" || $SYSTEM_ARCH == "aarch64" || $SYSTEM_ARCH == "amd64" ]]; then
      SYSTEM_ARCH="64"
  elif [[ $SYSTEM_ARCH == "i686" || $SYSTEM_ARCH == "i386" ]]; then
      SYSTEM_ARCH="32"
  elif [[ $SYSTEM_ARCH == "armv7l" ]]; then
      SYSTEM_ARCH="7"
  else
      log_message "${RED}Error: Unsupported system architecture ($SYSTEM_ARCH)${CLEAR_COLOR}"
      exit 1
  fi
  CPU_TYPE=$(lscpu | awk '/Vendor ID:/ {print $3}')
  if [[ $CPU_TYPE == "AuthenticAMD" || $CPU_TYPE == "GenuineIntel" ]]; then
    CPU_TYPE="amd"
  elif [[ $CPU_TYPE == "ARM" ]]; then
    CPU_TYPE="arm"
  else
    log_message "${RED}Error: System CPU unrecognized ($CPU_TYPE)${CLEAR_COLOR}"
    exit 1
  fi
  PLATFORM="${CPU_TYPE}${SYSTEM_ARCH}"
}

update_system() {
  printf "${RED}VERIFY ANY SCRIPT BEFORE RUNNING IT ON YOUR SYSTEM VIA ${UNDERLINE}CHAT.OPENAI.COM${CLEAR_COLOR}"
  echo " "

  log_message "${YELLOW}System will now update & will require password to do so${CLEAR_COLOR}"
  log_message "${YELLOW}Updating system now${CLEAR_COLOR}"
  $PACKAGE_MANAGER update && $PACKAGE_MANAGER upgrade -y
  log_message "${GREEN}System update completed!${CLEAR_COLOR}"
}

# Function to install dependencies 
install_dependencies() {
  log_message "${YELLOW}Installing dependencies.${CLEAR_COLOR}"
  if $PACKAGE_MANAGER install git -y; then
    log_message "${GREEN}Dependencies installed!${CLEAR_COLOR}"
  else 
    log_message "${RED}Failed to install necessary packages.${CLEAR_COLOR}"
    exit 1
  fi
}

# Function to set custom node and mining type
set_node_and_mining_type() {
  read -rp "Enter desired node to mine to or press 'ENTER' to skip & use the script default: " CUSTOM
  echo " "
  read -rp "Please enter desired mining type ('pool' or 'solo' are the only accepted responses): " MINING_TYPE
  echo " "
  while [[ $VALID_INPUT == false ]]; do
    VALID_INPUT=false
    if [[ $MINING_TYPE == "solo" || $MINING_TYPE == "SOLO" || $MINING_TYPE == "S" || $MINING_TYPE == "s" ]]; then
      PORT=${SOLO_PORT}
      MINING_TYPE="SOLO"
      log_message "${GREEN}Successfully set mining type to: $MINING_TYPE, utilizing port $PORT${CLEAR_COLOR}"
      echo " "
      VALID_INPUT=true
    elif [[ $MINING_TYPE == "pool" || $MINING_TYPE == "POOL" || $MINING_TYPE == "p" || $MINING_TYPE == "P" ]]; then
      PORT=${POOL_PORT}
      MINING_TYPE="POOL"
      log_message "${GREEN}Successfully set mining type to $MINING_TYPE, utilizing port $PORT${CLEAR_COLOR}"
      echo " "
      VALID_INPUT=true
    else
      log_message "${RED}Invalid mining type. Please enter 'solo' or 'pool'.${CLEAR_COLOR}"
      echo " "
      VALID_INPUT=false
    fi
  done
  if [[ -z $CUSTOM ]]; then
    log_message "${GREEN}Using default node.${CLEAR_COLOR}"
    echo " "
    if [[ "$MINING_TYPE" == "solo" ]]; then
      NODE="${NODE_ADDRESS}${BASE_ADDRESS}:${SOLO_PORT}"
    elif [[ "$MINING_TYPE" == "pool" ]]; then
      NODE="${POOL_ADDRESS}${BASE_ADDRESS}:${POOL_PORT}"
    fi
  elif [[ $CUSTOM == "*" ]]; then
    NODE="${CUSTOM}:10100"
  fi
  echo " "
}


# Function to set wallet address & register address if they do not have one
set_wallet_address() {
  read -rp "Paste your dero address here: " ANSWER
  if [[ $ANSWER =~ ^dero[a-z0-9]{62}$ ]]; then
    DERO_ADDRESS="$ANSWER"
    echo " "
    log_message "${GREEN}You will mine to the address: "${DERO_ADDRESS}"${CLEAR_COLOR}"
    echo " "
  else
    log_message "${RED}Error: setting dero address, ensure you enter full length of address. Human readable address will not work.${CLEAR_COLOR}"
    exit 1
  fi
}

# Function to set amount of threads available
set_threads_count() {
  log_message "${GREEN}Your system has an ${PLATFORM} processor with ${CPU_THREADS} threads for mining.${CLEAR_COLOR}"
  echo " "
  local VALID_INPUT=false
  while [[ $VALID_INPUT == false ]]; do
    read -rp "Choose even # below ${CPU_THREADS} to mine with: " NO_THREADS 
    echo  " "
    if [[ $NO_THREADS =~ ^[0-9]+$ ]]; then
      NUMBER=$((NO_THREADS))   
      if (( NUMBER > 0 && NUMBER <= CPU_THREADS && NUMBER % 2 == 0 )); then
        VALID_INPUT=true
        log_message "${GREEN}You entered: $NUMBER threads.${CLEAR_COLOR}"
      else
        log_message "${RED}Invalid input. Please enter a valid even number less than or equal to ${CPU_THREADS}.${CLEAR_COLOR}"
      fi
    else
      log_message "${RED}Invalid input. Please enter a valid integer.${CLEAR_COLOR}"
    fi
  done
}


# Function to download miner
hansen33_miner() {
  log_message "${YELLOW}Script will now download hansen33's miner for use.${CLEAR_COLOR}"
  echo " " 
  if [[ -f "./hansen33"* ]]; then
    log_message "${GREEN}Miner is already downloaded.${CLEAR_COLOR}"
    echo " "
  else
    log_message "${YELLOW}Downloading hansen33 miner.${CLEAR_COLOR}"
    wget "https://github.com/Hansen333/Hansen33-s-DERO-Miner/releases/download/Version-0.6/hansen33s-dero-miner-$OS_TYPE-$PLATFORM.tar.gz" || handle_error "Failed to download Hansen33 miner."
    tar -xvf hansen33*.tar.gz || handle_error "Failed to extract Hansen33 miner."
    rm hansen33*.tar.gz
    chmod +x hansen33*
    log_message "${GREEN}Hansen33 miner successfully downloaded.${CLEAR_COLOR}"
    echo " "
  fi
}

# Function to display variables
display_variables() {
  log_message "${MAGENTA}${UNDERLINE}The following are the settings you chose to use for your miner:${CLEAR_COLOR}"
  log_message "${MAGENTA}Wallet: $DERO_ADDRESS"
  log_message "Number of CPU threads to use: $NUMBER / $CPU_THREADS"
  log_message "Mining type: $MINING_TYPE, which mines to: '${NODE}'"
  log_message "If you desire to mine with different settings you must run this script and enter them then in order to create the correct script to run the miner.${CLEAR_COLOR}"
}

# Function to build mining script
build_script() {
  read -rp "If everything is correct above then press 'ENTER' to continue, otherwise you must press 'ctrl+z' and start over."
  echo " "
  WORKERS=$((NO_THREADS / 2))
  SCRIPT_NAME="${NODE}_${NO_THREADS}.sh"
  echo "#!/data/data/com.termux/files/usr/bin/bash" >> ${SCRIPT_NAME}
  echo " " >> ${SCRIPT_NAME}
  echo "./hansen33* --wallet-address ${DERO_ADDRESS} --mining-threads 2 --workers ${WORKERS} --daemon-rpc-address ${NODE} --turbo" >> ${SCRIPT_NAME}
  chmod +x ${SCRIPT_NAME}
  bash ${SCRIPT_NAME}

}

# run functions to set remaining variables
print_header
echo " "
log_message "{$GREEN}Script started.${CLEAR_COLOR}"

set_package_manager
update_system
install_dependencies
set_platform
set_threads_count
set_wallet_address
set_node_and_mining_type
hansen33_miner
display_variables
build_script
