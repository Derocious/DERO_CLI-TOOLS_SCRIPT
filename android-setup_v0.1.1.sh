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
  ${CYAN}${BOLD}<================================================================>
       ${RED}(         (       )      *    (       ) (       ) 
       /\ )      )\ ) ( /(    (     )\ ) ( /( )\ ) ( /( (      
      (()/(  (  (()/( )\())   )\))( (()/( )\()|()/( )\()))\ )   
      /(_)) )\  /(_)|(_)\   ((_)()\ /(_)|(_)\ /(_)|(_)\(()/(   
      (_))_ ((_)(_)) ((_)  (_()((_|_))  _((_|_))  _((_)/(_))_${CLEAR_COLOR}   
      ${BOLD}|   \| __| _ \ / _ \  |  \/  |_ _|| \| |_ _|| \| (_)) __|
      | |) | _||   /| (_) | | |\/| || | | .  || | | .  | | (_ |
      ${UNDERLINE}|___/|___|_|_\ \___/${CLEAR_COLOR}  ${UNDERLINE}|_|  |_|___||_|\_|___||_|\_|__\___|${CLEAR_COLOR}                                                                                                                                                                                                                                                                                                         
              Incentivize features here: ${GREEN}${BOLD}${UNDERLINE}derocious${CLEAR_COLOR}
        ${BOLD}${UNDERLINE}INCLUDE DESIRED FEATURE IN THE COMMENT OF TRANSACTION${CLEAR_COLOR} 
 ${CYAN}${BOLD} <================================================================>
${CLEAR_COLOR}${RED}ALWAYS CONFIRM WHAT A SCRIPT DOES BEFORE RUNNING IT ON YOUR MACHINE. 
              ${UNDERLINE}IF NOT BY YOU YOURSELF, USE CHATGPT${CLEAR_COLOR}"                                                                                                        
}


# Environment variables
BASE_ADDRESS='mysrv.cloud'
NODE_ADDRESS='dero-node.'
POOL_ADDRESS='community-pools.'
POOL_PORT=10300
SOLO_PORT=10100
RPC_PORT=10102
CUSTOM_PORT=0
PACKAGE_MANAGER="pkg"
CPU_THREADS=$(nproc)
LOG_FILE="script_status.log"
OS_TYPE="linux"
DERO_ADDRESS=" "

# Repositories used in script
FASTREG_REPO="https://github.com/Derocious/fastreg.git"
HANSEN33S_MINER_REPO="https://github.com/Hansen333/Hansen33-s-DERO-Miner/"




# Function to log messages to both stdout and a log file
log_message() {
  local MESSAGE=$1
  local PLAIN_MESSAGE=$(echo -e "${MESSAGE}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
  printf "${MESSAGE}"
  echo " "
  echo "$(date +'%Y-%m-%d %H:%M:%S'): ${PLAIN_MESSAGE}" >> "$LOG_FILE"
  echo " "
}


fastreg_new_address() {
  git clone ${FASTREG_REPO}
  cd fastreg
  go get
  go build
  chmod +x fastreg
  printf "${YELLOW}Registering new wallet address. This may take some time, be patient${CLEAR_COLOR}" | tee ../${LOG_FILE}
  echo " "
  printf "${YELLOW}YOUR SEED PHRASE AND WALLET INFO IS IN THE 'VERYIMPORTANT.txt' file. KEEP IT SAFE.${CLEAR_COLOR}" | tee ../${LOG_FILE}
  echo " "
  ./fastreg --daemon-address=${NODE_ADDRESS}${BASE_ADDRESS}:${RPC_PORT} >> ../VERYIMPORTANT.txt
  if [ $(wc -l < ../VERYIMPORTANT.txt) -ge 5 ]; then
    DERO_ADDRESS=$(sed -n '2p' ../VERYIMPORTANT.txt)
    if [[ $DERO_ADDRESS  =~ ^dero[a-z0-9]{62}$ ]]; then
      printf "${GREEN}Wallet address successfully set to: ${DERO_ADDRESS}${CLEAR_COLOR}" | tee ../${LOG_FILE}
      echo " "
      printf "${YELLOW}Your seed phrase is: $(sed -n '3p' ../VERYIMPORTANT.txt)${CLEAR_COLOR}"
      echo " "
      VALID_ADDRESS=true
    else 
      printf "${RED}ERROR: Address generation failed${CLAER_COLOR}" | tee ../${LOG_FILE}
      echo " "
      exit 1
    fi
  else
    printf "${RED}ERROR: Failed to register new address${CLEAR_COLOR}" | tee ../${LOG_FILE}
    echo " "
    exit 1
  fi
  cd ..
  rm -rf fastreg/
}

# Function to set wallet address & register address if they do not have one
set_wallet_address() {
  local VALID_ADDRESS=false
  while [[ $VALID_ADDRESS == false ]]; do
    read -rp "Paste your DERO address here or press ENTER to register a new address: " ANSWER
    if [[ $ANSWER =~ ^dero[a-z0-9]{62}$ ]]; then
      DERO_ADDRESS="$ANSWER"
      log_message "${GREEN}Address set to: ${DERO_ADDRESS}${CLEAR_COLOR}"
      echo " "
      VALID_ADDRESS=true
    elif [[ -z $ANSWER ]]; then
      log_message "${YELLOW}You have skipped entering an address${CLEAR_COLOR}"
      read -rp "Would you like to register a new wallet address? (y/n) " NEW_ADDRESS
        if [[ $NEW_ADDRESS =~ ^[Yy]$ ]]; then
          log_message "${YELLOW}You chose to register a new wallet address.${CLEAR_COLOR}"
          fastreg_new_address
        elif [[ $NEW_ADDRESS =~ ^[Nn]$ ]]; then
          log_message "${YELLOW}You chose not to register a new address${CLEAR_COLOR}"
          VALID_ADDRESS=false
        else 
          log_message "${RED}ERROR: You must enter either 'y' or 'n'${CLEAR_COLOR}"
        fi
    else
      log_message "${RED}ERROR: Address format incorrect, please enter full address.${CLEAR_COLOR}"
      VALID_ADDRESS=false
    fi
  done
}

# Function to determine CPU type and system architecture
set_platform() {
  SYSTEM_ARCH=$(uname -m)
  if [[ $SYSTEM_ARCH == "x86_64" || $SYSTEM_ARCH == "aarch64" || $SYSTEM_ARCH == "amd64" ]]; then
      SYSTEM_ARCH="64"
  elif [[ $SYSTEM_ARCH == "i686" || $SYSTEM_ARCH == "i386" || $SYSTEM_ARCH == "armv8l" ]]; then
      SYSTEM_ARCH="32"
      log_message "${RED}ERROR: 32 bit processor not currently supported${CLEAR_COLOR}"
      exit 1
  elif [[ $SYSTEM_ARCH == "armv7l" ]]; then
      SYSTEM_ARCH="7"
      log_message "${RED}ERROR: 7 bit processor not currently supported${CLEAR_COLOR}"
      exit 1
  else
      log_message "${RED}ERROR: Unsupported system architecture ($SYSTEM_ARCH)${CLEAR_COLOR}"
      exit 1
  fi
  CPU_TYPE=$(lscpu | awk '/Vendor ID:/ {print $3}')
  if [[ $CPU_TYPE == "AuthenticAMD" || $CPU_TYPE == "GenuineIntel" ]]; then
    CPU_TYPE="amd"
  elif [[ $CPU_TYPE == "ARM" ]]; then
    CPU_TYPE="arm"
  else
    log_message "${RED}ERROR: System CPU unrecognized ($CPU_TYPE)${CLEAR_COLOR}"
    exit 1
  fi
  PLATFORM="${CPU_TYPE}${SYSTEM_ARCH}"
}

update_system() {
  log_message "${YELLOW}Updating system.${CLEAR_COLOR}"
  $PACKAGE_MANAGER update && $PACKAGE_MANAGER upgrade -y
  log_message "${GREEN}System update complete!${CLEAR_COLOR}"
}

# Function to install dependencies 
install_dependencies() {
  log_message "${YELLOW}Installing dependencies.${CLEAR_COLOR}"
  if $PACKAGE_MANAGER install git wget golang jq -y; then
    log_message "${GREEN}Dependencies installed!${CLEAR_COLOR}"
  else 
    log_message "${RED}ERROR: Failed to install necessary packages.${CLEAR_COLOR}"
    exit 1
  fi
}

# Function to set custom port
set_custom_port() {
  log_message "${GREEN}Custom node set: $CUSTOM${CLEAR_COLOR}"
  while true; do
    read -rp "Enter PORT: " CUSTOM_PORT
    if [[ $CUSTOM_PORT =~ ^[0-9]+$ ]]; then
      log_message "${GREEN}Custom port set: $CUSTOM_PORT${CLEAR_COLOR}"
      NODE="${CUSTOM}:${CUSTOM_PORT}"
      log_message "${GREEN}Mining to: $NODE${CLEAR_COLOR}"
      break
    else
      log_message "${RED}Invalid port. Please enter a valid number.${CLEAR_COLOR}"
    fi
  done
}


# Function to set custom node and mining type
set_mining_type_and_node() {
  read -rp "Enter custom node address to mine to or press 'ENTER' to skip & use the script default: " CUSTOM
  echo " "
  if [[ $CUSTOM ]]; then
    set_custom_port
  else
    log_message "${GREEN}Default node selected.${CLEAR_COLOR}"
    local VALID_INPUT=false
    while [[ $VALID_INPUT == false ]]; do
      read -rp "Enter mining type ('pool' or 'solo' are the only accepted responses): " MINING_TYPE
      if [[ $MINING_TYPE == "solo" || $MINING_TYPE == "SOLO" || $MINING_TYPE == "S" || $MINING_TYPE == "s" ]]; then
        PORT=${SOLO_PORT}
        MINING_TYPE="solo"
        NODE="${NODE_ADDRESS}${BASE_ADDRESS}:${SOLO_PORT}"
        log_message "${GREEN}Mining type set to: ${MINING_TYPE}${CLEAR_COLOR}"
        log_message "${GREEN}Node set to: ${NODE}${CLEAR_COLOR}"
        echo " "
        VALID_INPUT=true
      elif [[ $MINING_TYPE == "pool" || $MINING_TYPE == "POOL" || $MINING_TYPE == "p" || $MINING_TYPE == "P" ]]; then
        PORT=${POOL_PORT}
        MINING_TYPE="pool"
        NODE="${POOL_ADDRESS}${BASE_ADDRESS}:${POOL_PORT}"
        log_message "${GREEN}Mining type set to: ${MINING_TYPE}${CLEAR_COLOR}"
        log_message "${GREEN}Node set to: ${NODE}${CLEAR_COLOR}"
        echo " "
        VALID_INPUT=true
      else
        log_message "${RED}Invalid mining type. Please enter 'solo' or 'pool'.${CLEAR_COLOR}"
        echo " "
        VALID_INPUT=false
      fi
    done
  fi
}

# Function to set amount of threads available
set_threads_count() {
  log_message "${YELLOW}Your system has an ${PLATFORM} processor with ${CPU_THREADS} threads for mining.${CLEAR_COLOR}"
  local VALID_INPUT=false
  while [[ $VALID_INPUT == false ]]; do
    read -rp "Choose even # ${CPU_THREADS} or below to mine with: " NO_THREADS 
    echo  " "
    if [[ $NO_THREADS =~ ^[0-9]+$ ]]; then
      NUMBER=$((NO_THREADS))   
      if (( NUMBER > 0 && NUMBER <= CPU_THREADS && NUMBER % 2 == 0 )); then
        VALID_INPUT=true
        log_message "${GREEN}Number of threads selected: $NUMBER${CLEAR_COLOR}"
      else
        log_message "${RED}ERROR: Invalid input. Please enter a valid even number less than or equal to ${CPU_THREADS}.${CLEAR_COLOR}"
      fi
    else
      log_message "${RED}ERROR: Invalid input. Please enter a even number less than or equal to ${CPU_THREADS}.${CLEAR_COLOR}"
    fi
  done
}

# Function to download latest version of Hansen33 miner
hansen33_miner() {
  log_message "${YELLOW}Checking for the latest version of Hansen33 miner.${CLEAR_COLOR}"
  latest_version=$(curl -s "https://api.github.com/repos/Hansen333/Hansen33-s-DERO-Miner/releases/latest" | jq -r '.tag_name')
  if [[ -z $latest_version ]]; then
    log_message "${RED}ERROR: Github API call failed to retrieve the latest version information.${CLEAR_COLOR}"
    exit 1
  fi
  log_message "${GREEN}Latest version found: $latest_version${CLEAR_COLOR}"
  download_url="https://github.com/Hansen333/Hansen33-s-DERO-Miner/releases/download/$latest_version/hansen33s-dero-miner-$OS_TYPE-$PLATFORM.tar.gz"
  log_message "${YELLOW}Downloading Hansen33 miner version $latest_version.${CLEAR_COLOR}"
  wget "$download_url" || log_message "${RED}ERROR: Failed to download Hansen33 miner.${CLEAR_COLOR}"
  tar -xvf hansen33*.tar.gz || log_message "${RED}ERROR: Failed to extract Hansen33 miner.${CLEAR_COLOR}"
  rm hansen33*.tar.gz
  chmod +x hansen33*
  echo " "
  log_message "${GREEN}Hansen33 miner version $latest_version successfully downloaded.${CLEAR_COLOR}"
  echo " "
}

# Function to display variables
display_variables() {
  local PERCENTAGE=$((100 * NUMBER / CPU_THREADS))  
  log_message "${UNDERLINE}The following are the settings you chose to use for your miner:${CLEAR_COLOR}"
  log_message "${BLUE}Wallet: $DERO_ADDRESS"
  log_message "Number of CPU threads to use: $NUMBER / $CPU_THREADS ($PERCENTAGE%% power)"
  log_message "Mining type: $MINING_TYPE, which mines to: '${NODE}'${CLEAR_COLOR}"
  log_message "${YELLOW}If you press 'ENTER' these settings will be used to create a new script that can be used to run your miner at any time with these predetermined settings."
  log_message "${YELLOW}It will be named '${NODE}_${NUMBER}.sh' & can be run by entering './${NODE}_${NUMBER}.sh'${CLEAR_COLOR}"
  echo " "
}

# Function to build mining script
build_script() {
  read -rp "If everything is correct above then press 'ENTER' to continue, otherwise you must press 'ctrl+z' and start over."
  echo " "
  WORKERS=$((NO_THREADS / 2))
  SCRIPT_NAME="${NODE}_${NUMBER}.sh"
  echo "#!/data/data/com.termux/files/usr/bin/bash" >> ${SCRIPT_NAME}
  echo " " >> ${SCRIPT_NAME}
  echo "./hansen33* --wallet-address ${DERO_ADDRESS} --mining-threads 2 --workers ${WORKERS} --daemon-rpc-address ${NODE} --turbo" >> ${SCRIPT_NAME}
  chmod +x ${SCRIPT_NAME}
  bash ${SCRIPT_NAME}

}

print_header
echo " "
log_message "${GREEN}Initiating script.${CLEAR_COLOR}"

update_system
install_dependencies
set_platform
set_threads_count
set_wallet_address
set_mining_type_and_node
hansen33_miner
display_variables
build_script
