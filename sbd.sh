#!/bin/bash
#____   ____             __                
#\   \ /   /____   _____/  |_  ___________ 
# \   Y   // __ \_/ ___\   __\/  _ \_  __ \
#  \     /\  ___/\  \___|  | (  <_> )  | \/
#   \___/  \___  >\___  >__|  \____/|__|   
#              \/     \/     
#--Licensed under GNU GPL 3
#----Authored by Vector/NullArray
##############################################

# Coloring scheme for notfications and logo
ESC="\x1b["
RESET=$ESC"39;49;00m"
CYAN=$ESC"33;36m"
RED=$ESC"31;01m"
GREEN=$ESC"32;01m"

# Store working directory
cwd=$(pwd)

# Default output
dirname="/tmp"

# Warning
function warning(){
	echo -e "$RED [!] $1 $RESET"
	}

# Green notification
function notification(){
	echo -e "$GREEN [+] $1 $RESET"
	}

# Cyan notification
function notification_b(){
	echo -e "$CYAN [-] $1 $RESET\n"
	}

# Function to print banner logo
function logo(){
	clear
	echo -e "$CYAN
.________._______ .______  
|    ___/: __   / :_ _   \ 
|___    \|  |>  \ |   |   |
|       /|  |>   \| . |   |
|__:___/ |_______/|. ____/ 
   :               :/      
                   :       $RESET"
	}

# Check for utils and machine type.
# We're checking for GCC and MAKE in order 
# to be able to deploy BusyBox by building 
# from source if we encounter an unkown
# machine or architecture type.
function checker(){
	notification_b "Checking utils...\n"
	
	sleep 2 
	
	# Check for GCC
	COMPILER=`which gcc`
	if [[ ${COMPILER} == "/usr/bin/gcc" || ${COMPILER} == "/bin/gcc" ]]; then
		echo -e "$GREEN [+] $RESET gcc found."
		gcc_present=1
	else
		echo -e "$RED [!] $RESET gcc not found."
		gcc_present=0
	fi
	
	# Check for make
	MAKE=`which make`
	if [[ ${MAKE} == "/usr/bin/make" || ${COMPILER} == "/bin/make" ]]; then
		echo -e "$GREEN [+] $RESET make found."
		make_present=1
	else
		echo -e "$RED [!] $RESET make not found."
		make_present=0
	fi
	
	}

# Operations to compile BusyBox if needed
function compile(){
	notification_b "\nCompiling BusyBox\n"
	
	sleep 2
	
	cd $dirname/busybox-1.29.3
	make defconfig && clear
	make
	cd $cwd
	
	notification "\n\nDone\n\n"
	
	}

# Function to get BusyBox	
function busybox(){	
	# Check Arch/Machine type 
	MACHINE_TYPE=`uname -i`
	if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
		wget -O $dirname/BusyBox https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64
	else
		wget -O $dirname/BusyBox https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-${MACHINE_TYPE} || clear && build=1
	fi
	
	# If there's an Architecture not supported on busybox.net, URI:busybox-${MACHINE_TYPE}
	# will refer to a nonexistant resource, as such wget will not be able to download it
	# We `stat $dirname/BusyBox` to see if a succesful download occurred, if not, we'll
	# download source and attempt to build generic busybox locally to compensate.
	stat $dirname/BusyBox > /dev/null && chmod +x $dirname/BusyBox || build=1 
	
	if [[ $build == 1 ]]; then	
		echo -e "$RED [!] $RESET Unrecognized machine or architecture type.\n"
	
		if [[ $gcc_present == 1 && $make_present == 1 ]]; then
			echo -e "$GREEN [+] $RESET Since 'make' and 'gcc' are available SBD will attempt"
			echo -e "$GREEN [+] $RESET to deploy BusyBox by building it from source intstead.\n"
			wget -O $dirname/BusyBox.tar.bz2 https://busybox.net/downloads/busybox-1.29.3.tar.bz2
			tar -xf $dirname/BusyBox.tar.bz2
			
			echo -e "$GREEN [+] $RESET Downloaded and extracted source code."
			
			rm -rf BusyBox.tar.bz2
			compile
		else
			warning "Can not build BusyBox from source"
        fi
			
	fi
    }

function net_utils(){
	logo
	notification_b "\nThis operation will download the following binaries.\n"
	
	echo -e "[1] Ncat"
	echo -e "[2] Nmap"
	echo -e "[3] Ngrok"
	echo -e "[4] Socat\n" 
	
	read -p 'Continue? [Y/n] ' choice
	
	if [[ $choice == 'y' || $choice == 'Y' ]]; then
		notification_b "\nDownloading..."
		
		wget -O $dirname/ncat https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/ncat
		wget -O $dirname/nmap https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/nmap
		wget -O $dirname/socat https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat
		wget -O $dirname/ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
		
		notification "\nDone"
		echo -e "Unzipping Ngrok..."
		
		unzip $dirname/ngrok.zip -d $dirname
		notification "\nDone"
    fi
	}

function deploy_all(){
	# Print logo
	logo
	
	# Check for GCC and MAKE 
	checker
	
	# Download or build Busybox
	busybox

	# Download net utility binaries
	net_utils			
	
	notification "Done"	
	
	}

function usage(){
	# Print logo
	logo
	
	notification_b "Welcome to Static Binary Deployer"
	echo -e "\
As a post exploitation tool, this script is designed 
to give the user access to Linux utilities that may
otherwise be unavailabe, depending on the security
context from which you're working on the compromised
system.

As such SBD Utilities may prove helpful in enumeration,
persistence, exploitation, and privilege escalation in
combination with other tools.\n"

	notification_b "Usage Overview"
	echo -e "\
1. The 'Help' option shows this informational message.

2. The 'Set Outpath' option allows you to define a directory
to which the static binaries will be deployed.

3. 'Deploy All' downloads all static binaries available with
this tool.

4. 'Deploy BusyBox' downloads a BusyBox binary with built-in
Linux Utilities.

5. Choosing the 'Deploy Net Utilities' option will download
static binaries for Ncat, Socat, Nmap, and Ngrok which
is a portforwarding/tunneling utility.  	

6.'Clean up' removes all downloaded files and;

7.'Quit' exits SBD.\n"

	}

logo

PS3='Please enter your choice: '
options=("Help" "Set Outpath" "Deploy All" "Deploy BusyBox" "Deploy Net Utilities" "Clean up" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Help")
            usage
            printf "%b \n"
            ;;
        "Set Outpath")
	    echo -e "$CYAN [i] $RESET Current outpath is set to $dirname\n"
	    read -p 'Change output directory? [Y/n] ' choice
		
	    if [[ $choice == 'y' || $choice == 'Y' ]]; then
		read -p '\n Enter new outpath: ' dirname
		# Check if valid
		stat $dirname > /dev/null || notification_b "Invalid Path. Creating $dirname instead"
		# Create directory or fall back to default in case we can't
		mkdir $dirname || warning "Could not create directory. Defaulting to /tmp/" && dirname="/tmp"
      	    else
		echo -e "$CYAN [i] $RESET Outpath was not changed"
	    fi
				
	    printf "%b \n"
            ;;
        "Deploy All")
	    deploy_all
	    printf "%b \n"
	    ;;
        "Deploy BusyBox")
            checker
	     busybox
            printf "%b \n"
            ;;
        "Deploy Net Utilities")
            net_utils
            printf "%b \n"
            ;;
         "Clean up")
            echo "Removing downloaded files"
            find $dirname/* -exec rm {} \;
            printf "%b \n"
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
