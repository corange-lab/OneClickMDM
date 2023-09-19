#!/bin/bash

RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}===========================================${NC}"
echo -e "${YEL}   MDM Bypass for MacOS - ONECLICKMDM      ${NC}"
echo -e "${RED}           Presented by CORANGE LAB        ${NC}"
echo -e "${CYAN}===========================================${NC}"
echo ""

# Initiating MDM Bypass in Recovery Mode
echo -e "${GRN}Initiating MDM bypass in recovery mode...${NC}"
if [ -d "/Volumes/Macintosh HD - Data" ]; then
   	diskutil rename "Macintosh HD - Data" "Data"
    echo -e "${GREEN}Renamed the volume successfully.${NC}"
fi

# User Creation Prompt
echo -e "${GRN}Proceeding with user creation...${NC}"
echo -e "${BLU}If you wish to use default settings, simply press Enter. For a custom setup, follow the prompts.${NC}"
echo -e "Enter a username (Default: Apple, without spaces): "
read realName
realName="${realName:= Apple}"
echo -e "${BLUE}Confirm your username (Default: Apple):${NC}"
read username
username="${username:=Apple}"
echo -e "${BLUE}Set a password (default: 1234):${NC}"
read passw
passw="${passw:=1234}"

dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
echo -e "${GREEN}Setting up the new user...${NC}"

# User Creation
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
mkdir "/Volumes/Data/Users/$username"
dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership $username

# Blocking MDM-related domains
echo -e "${GREEN}Blocking MDM-related domains...${NC}"
echo "0.0.0.0 deviceenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
echo "0.0.0.0 mdmenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
echo "0.0.0.0 iprofiles.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
echo -e "${GREEN}Domains blocked successfully.${NC}"

# Adjusting MDM-related files
echo -e "${GREEN}Adjusting system files related to MDM...${NC}"
touch /Volumes/Data/private/var/db/.AppleSetupDone
rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound

echo -e "${GRN}MDM bypass completed successfully!${NC}"
echo ""
echo -e "${YEL}===========================================${NC}"
echo -e "${PUR}  Thank you for using ONECLICKMDM!         ${NC}"
echo -e "${YEL}    Your MacBook will restart shortly.     ${NC}"
echo -e "${YEL}===========================================${NC}"

# Wait for 10 seconds
sleep 10

# Restart the MacBook
reboot

# Command to close terminal (may depend on which terminal you're using, the below is for the default Terminal.app)
osascript -e 'tell application "Terminal" to quit'

