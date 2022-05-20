#!/bin/bash
#########################################################################################################################
#########################################################################################################################
#Script Name    : Troubleshooting Wizard NMIS9 OPMANTEK
#Description    : Welcome to the Troubleshooting tool, here you will find some useful options
#                 for analyzing, checking and diagnosing the NMIS monitoring system.
#link           : https://community.opmantek.com/display/NMISES/Manual+descriptivo+del+Troubleshooting+Wizard
#Author         : Arnulfo N. Garcia Perez
#Email          : arnulfog@opmantek.com | arnulfo.tom.tics@gmail.com
#Usage          : ./01_TS_Wizard_OMK.sh
#########################################################################################################################
#########################################################################################################################
# Requirement: The script requires to be executed with "root" user, it also uses secondary scripts
# so they need to be integrated to the indicated directories, please read the instructions.
#########################################################################################################################


### Colors ##
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

### Color Functions ##
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }
fn_bye() { echo "Bye bye."; exit 0; }
fn_fail() { echo "Wrong option, enter a valid option"; }

### Section HealthCheck ##
sub_submenuTop() {
clear
echo -e "\n
┌────────────────────────   Execute HealthCheck  TOP .────────────────────────────────┐
  The top half of the output contains statistics on processes and resource usage,
  while the bottom half contains a list of currently running processes.
└─────────────────────────────────────────────────────────────────────────────────────┘\n"
#ctop="$(top -bn1)" #complete
echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
ctop="$(top -n1)"
echo "$ctop "
echo -e "\nSummary: Review uptime section, average system load, Tasks, Processes, CPU States,
    Physical Memory, Virtual Memory and Columns, this will help to see the O.S. status.  "

#Tips::
    #Load Average-------------------------
    # Retrieve the average load
    LOAD_AVG=`uptime | cut -d'l' -f2 | awk '{print $3}' | cut -d. -f1`
    LOAD_CURRENT=`uptime | cut -d'l' -f2 | awk '{print $3 " " $4 " " $5}' | sed 's/,//'`
    # Define the threshold. This value will be compared to the current load average.
    # load average. Set the value as required.
    LIMIT=0 #Set value
    # compare the current load average with the Threshold value and
    # makes a recommendation or tip
    if [ $LOAD_AVG -gt $LIMIT ]
    then
echo -ne "$(magentaprint 'Details:')\n"
echo "Load average :: $LOAD_AVG"
echo "Current Load Average :: $LOAD_CURRENT"
echo -ne "
 $(blueprint 'TIPS TO RESOLVE AN ISSUE:')
 $(redprint 'Check the processes with more CPU load.')
 $(redprint 'Check the processes with more memory usage.')
 $(redprint 'Check the I/O performance')"

fi
##Zombie-------------------------
      LZombie=1 #Set value
      NZombie=`ps -A -ostat,ppid | grep -e '[zZ]'| awk '{ print $2 }' | wc -w`
      DZombie=`ps auxwww --width 20 | grep -e '[zZ]'`
      if [ $NZombie -gt $LZombie ]; then
echo -ne "$(magentaprint 'Details:')\n"
echo "Number of zombie processes :: $NZombie"
echo "Current Load Average :: $DZombie"
echo -ne "
 $(blueprint 'TIPS TO RESOLVE AN ISSUE:')
 $(redprint 'Review processes -Multiple processes are in Zombien state.')
 $(redprint 'Check that there are no glued processes.')
 $(redprint 'Check Processes waiting for I/O operations')"


      fi
##Memory-------------------------
      LMemory=15 #Set value
      Musage=$(free | awk '/Mem/{printf("RAM Usage: %.2f%\n"), $3/$2*100}' |  awk '{print $3}' | cut -d"." -f1)
      MStatus=`free -m`
      if [ $Musage -ge $LMemory ]; then
echo -ne "$(magentaprint 'Details:')\n"
echo "Current Memory Usage :: $Musage%"
echo -e "MEMORY :: \n $MStatus"
        echo -ne "
 $(blueprint 'TIPS TO RESOLVE AN ISSUE:')
 $(redprint 'Check disk partition.')
 $(redprint 'Cleaning of big log files.')
 $(redprint 'Search for big files.')
 $(redprint 'Delete cache.')"

      fi
      echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
    $(blueprint 'r)') Repeat    $(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu    $(redprint 'e)') Exit
      Choose an option:  "
      read -r ans
      case $ans in
      r|R)
        sub_submenuTop
        ;;
      b|B)
        subHealthCheck
        ;;
      m|M)
        mainmenu
        ;;
      e|E)
        fn_bye
        ;;
      *)
        fn_fail
        sub_submenuTop
        ;;
      esac
}
sub_submenuDateT() {
clear
echo -e "
┌────────────────   Execute HealthCheck System date and time    .─────────────────────┐
  Operating System date display and weather monitoring system settings.
└─────────────────────────────────────────────────────────────────────────────────────┘\n"

#RANCH_REGEX="^(develop$|release//*)"
echo -ne "$(blueprint '-- Operating System Date --')\n"
CTL_TIME="$(find /usr/share/  -name "timedatectl" | wc -l)"
      if [[ $CTL_TIME  == 0 ]];
      then
          date
          echo "Time Zone: $(date +'%:z %Z')"
          more /etc/sysconfig/clock
      else
          timedatectl
      fi
echo -ne "\n$(blueprint '-- Monitoring system "date" configuration --')\n"
more /usr/local/omk/conf/opCommon.json | grep "timezone"
echo -e "\n$(blueprint '-- Data and Configuration of the NTP Service --')\n"

NTP_TIME=`ps awx | grep 'ntp' |grep -v grep|wc -l`

      if [[ $NTP_TIME == 0 ]];
      then
        echo -ne "$(redprint 'The NTP service is not active on this server, \n contact the administrator to verify this status.')"
      else
          echo -ne "$(greenprint ' Status Service:\n') $(service ntpd status)\n"
          echo -ne "$(greenprint ' NTP STAT:')\n"
          ntpstat
          echo -ne "$(greenprint ' NTP STAT:')\n"
          ntpq -pn
      fi

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu   $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_submenuDateT
  ;;
esac
}
sub_subDiskRW() {
  clear
  echo -e "\n
┌────────────────────────────   Disk R/W  .────────────────────────────────┐
  -->  This test provides the speed of data transfer when reading or
       writing to the server's disk.
└──────────────────────────────────────────────────────────────────────────┘\n"
echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "$(greenprint 'Command:
dd if=/dev/zero of=/usr/local/omkTestFile bs=10M count=1 oflag=direct')\n"
dd if=/dev/zero of=/usr/local/omkTestFile bs=10M count=1 oflag=direct
echo -ne "\n$(greenprint 'Command:
dd if=/usr/local/omkTestFile of=/dev/null 2>&1')\n"
dd if=/usr/local/omkTestFile of=/dev/null 2>&1
echo -ne "
$(blueprint 'Parameters:')
$(redprint '0.0X s to be correct')
$(redprint '0.X s, there is a warning (and there would be issue)')
$(redprint 'X.0 s would be critical (and there would be a problem).')\n"

echo -e "\n Monitoring System in/out statistics for devices and partitions."
echo -e "--> 4 queries are made every 5 seconds \n"
echo -ne "$(greenprint 'Command:
iostat -x 5 4')\n"
iostat -x 5 4

echo -ne "
$(blueprint 'Parameters:')
$(redprint 'Using 100% iowait / Utilization indicates that there is a problem and in most
cases a big problem that can even lead to data loss. Essentially, there is a bottleneck
somewhere in the system. Perhaps one of the drives is preparing to die / fail.')"
echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subDiskRW
  ;;
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subDiskRW
  ;;
esac

}
sub_subFilesystem() {
  clear
  echo "
┌────────────────────────────   Filesystem  .────────────────────────────────┐
  -->  Check of partitions, directories, memory status, SWAP status.
└────────────────────────────────────────────────────────────────────────────┘"

echo -ne "\n$(blueprint '-- Show the amount of free disk space on each mounted disk --')\n"
echo "Command: df -h"
df -h
echo -ne "
 $(blueprint 'TIPS TO RESOLVE AN ISSUE:')
 $(redprint 'If any disk has more than 85% usage, contact the administrator
 and inform that the server is low on disk space.')\n"

echo -ne "\n$(blueprint '-- Displays information of all block devices --')\n"
echo "Command: lsblk"
lsblk -o NAME,MAJ:MIN,VENDOR,MODEL,SIZE,TYPE,FSTYPE,RO,MOUNTPOINT,OWNER,GROUP,MODE
echo -ne "\n$(blueprint '-- Partition list is sorted by name, integrating unit details, sector size, I/O size. --')\n"
fdisk -l  | more

echo -ne "$(blueprint '-- Display the amounts of memory used and available on the server --')\n"
echo "Command: free -mt"
free -mt
free=$(free -mt | grep Total | awk '{print $4}')
if [[ "$free" -le 700  ]]; then
#if [[ "$free" -le 9000  ]]; then
        ## get top processes consuming system memory and save to temporary file
        #ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
        echo -ne "\n$(redprint 'TIPS TO RESOLVE AN ISSUE:
Warning, server memory is filling up') \nFree memory: $free MB\n"
        echo -ne "$(redprint 'Contact the administrator and indicate what is happening')"
fi
#cat /proc/swaps
#cat /proc/meminfo
#du -hs /*  | sort -nr | head -10
echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subFilesystem
  ;;
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subFilesystem
  ;;
esac

}
sub_subServicestatus() {
  clear
  echo "
┌────────────────────────────   Service Status  .────────────────────────────────┐
  -->  Verification of the status of each service that influences the NMIS
       monitoring system.
└────────────────────────────────────────────────────────────────────────────────┘"
TIME=$(date +%Y-%m-%d_%T)
omk=`ps awx | grep 'opmantek' |grep -v grep|wc -l`
if [ $omk == 0 ];
    then
      echo -ne "\n$(blueprint 'The omkd service is stopped, if you want to start it you can run the command:') \n"
      echo -ne " $(redprint '--> service omkd start or service omkd restart')"

    else
      echo -ne "\n $(greenprint 'service ')omkd $(greenprint 'is running')"
fi
nmis9d=`ps awx | grep 'nmisd' |grep -v grep|wc -l`
if [ $nmis9d == 0 ];
    then
      echo -ne "\n$(blueprint 'The nmis9d service is stopped, if you want to start it you can run the command:') \n"
      echo -ne " $(redprint '--> service nmis9d start or service nmis9d restart')"

    else
      echo -ne "\n $(greenprint 'service ')nmis9d $(greenprint 'is running')"
fi
#Agregar/Omitir servicios segun sea necesario.
declare -a ARRAY=( "mongod " "httpd" "opchartsd" "opeventsd" "opconfigd" "opflowd" "crond" "snmpd" "iptables" )
for demon in "${ARRAY[@]}";do
if ps ax | grep -v grep | grep $demon > /dev/null
    then
      echo -ne "\n $(greenprint 'service ') $demon $(greenprint ' is running')"
    else
      echo -ne "\n
$(blueprint ' The ') $demon $(blueprint 'service is stopped, if you want to start it you can run the command:') \n"
      echo -ne " -->$(redprint ' service') $demon $(redprint 'start')\n"
      echo -ne " -->$(redprint ' service') $demon $(redprint 'restart')\n"
    fi
done
echo -e "NOTE: If the iptables service is disabled, this is correct since nmis does not require it,
if it is enabled, please disable it for the correct operation of the monitoring system."


echo -e "\nCheck the current state of SELinux (must be disabled). \n"
sestatus

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu   $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subServicestatus
  ;;
esac
}
sub_subLoadaverage() {
  clear
  echo -e "
┌────────────────────────────   Load Average  .────────────────────────────────┐
  -->  Linux load averages are "system load averages" that show the running
       thread (task) demand on the system as an average number of running plus
       waiting threads.
└──────────────────────────────────────────────────────────────────────────────┘\n"

echo -e "\nCommand: w \n"
w
echo -ne "$(redprint '
Some interpretations:

=> If the averages are 0.0, then your system is idle.
=> If the 1 minute average is higher than the 5 or 15 minute averages, then load is increasing.
=> If the 1 minute average is lower than the 5 or 15 minute averages, then load is decreasing.
=> If they are higher than your CPU count, then you might have a performance problem.')\n"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subLoadaverage
  ;;
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subLoadaverage
  ;;
esac
}
sub_subTop20processesbyCPU() {
  clear
  echo -e "\n
┌───────────────────────   Top 5 processes by CPU and Memory  .──────────────────────────┐
  -->  The 5 processes that currently consume the most memory are shown, in addition to
       CPU and memory details
└────────────────────────────────────────────────────────────────────────────────────────┘\n"

echo -ne "$(blueprint 'Query of the 5 processes that consume more percentage (%) of CPU in the server.')\n"
ps -Aeo user,pid,ppid,%mem,%cpu,stat,start,time,cmd --sort=-%cpu | head -n 6

echo -e "\n"
echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "\n$(blueprint 'Details CPU:')\n"
lscpu

echo -e "\n"
echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "\n\n$(blueprint 'Query of the 5 processes that consume more percentage (%) of MEMORY in the server.')\n"
ps -Aeo user,pid,ppid,%mem,%cpu,stat,start,time,cmd --sort=-%mem | head -n 6

echo -e "\n"
echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "\n$(blueprint 'Details Memory')\n"
lsmem

echo -ne "\n$(redprint 'TIPS TO RESOLVE AN ISSUE:
If the processes exceed 85% of the CPU or memory, please perform
an investigation, it could be a case of hung processes.')"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subTop20processesbyCPU
  ;;
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subTop20processesbyCPU
  ;;
esac
}
sub_subTcpdump() {
  clear
  echo -e "
┌───────────────────────────────────   TCPDUMP  .──────────────────────────────┐
  -->  Analysis of traffic flowing on the network (server interfaces).

└──────────────────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
IFInterface=`netstat -i | column -t | awk '{print $1}'| sed 's/Kernel//'| sed 's/Iface//' | head -n 6`
for i in $IFInterface; do
echo -ne "\n$(redprint '─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.─.')\n"
echo -ne "$(greenprint 'tcpdump -lnni') $i $(greenprint '-s0 -x port 162')\n"
cd /tmp/
      timeout 3 tcpdump -lnni $i -s0 -x port 162 -w capture_$i_$(hostname)_$(date +%Y%m%d_%T).pcap
      #tcpdump -nevi ens224 -X -x port 162
done

echo -ne "\n$(redprint 'NOTE:
In the /tmp/ directory you will find the .pcap files of the query,
this will help to better diagnose the problem, using Wireshark, for example..')
file name: capture_$(hostname)_* \n"

find /tmp -name "capture_$(hostname)_*" | tail -4
echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu   $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subTcpdump
  ;;
esac

}
sub_subIProutingtable() {
  clear
  echo -e "
┌──────────────────────────────   IP routing table  .──────────────────────────┐
  -->  View of subnets detected in the S.O.
└──────────────────────────────────────────────────────────────────────────────┘\n"
echo -ne "$(blueprint 'Display routing table in full')\n"
route -n

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu   $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subIProutingtable
  ;;
esac
}
sub_subListofloggedusers() {
  clear
  echo -e "
┌──────────────────────────    List of logged users  .─────────────────────────┐
  -->  Shows information about the users currently on the machine, and their
       processes.
└──────────────────────────────────────────────────────────────────────────────┘\n"

echo -e "\n"
w
echo -e "\n"
who -a

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subListofloggedusers
  ;;
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subListofloggedusers
  ;;
esac

}
sub_subLoguseraudit() {
  clear
  echo -e "\n
┌──────────────────────────    Log user audits  .─────────────────────────┐
  -->  Review of system logs, view of connected users, search for errors,
       critical messages, alerts in operating system logs.
└─────────────────────────────────────────────────────────────────────────┘\n"
####################
echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "$(blueprint 'Shows failed login attempts.') \n"
ausearch --message USER_LOGIN --success no --interpret
echo -ne "\n$(blueprint 'Shows all failed system calls from yesterday up until now.') \n"
ausearch --start yesterday --end now -m SYSCALL -sv no -i
echo -ne "\n$(blueprint 'Review of the /var/log/messages file for errors or failures') \n"
tail -n 100 /var/log/messages | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 10
echo -ne "\n$(blueprint 'Review of the /var/log/secure file for errors or failures') \n"
tail -n 100 /var/log/secure | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 10
echo -ne "\n$(blueprint 'Review of the /var/log/cron file for errors or failures') \n"
tail -n 100 /var/log/cron | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 10
echo -ne "\n$(blueprint 'Review of the /var/log/dmesg file for errors or failures') \n"
tail -n 100 /var/log/dmesg | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 10
echo -ne "\n$(blueprint 'Review of the /var/log/boot.log file for errors or failures') \n"
tail -n 100 /var/log/boot.log | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 10

echo -ne "\n$(redprint 'TIPS TO RESOLVE AN ISSUE:
If you see that the same user has many failed attempts to the system,
ask the administrator or the user if he has any problem with his password.') \n"
echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu   $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subLoguseraudit
  ;;
esac
}
sub_subShowlastusedcommands() {
  clear
  echo -e "\n
┌───────────────────────    Show last used commands  .────────────────────┐
  -->  The last commands that have been recently used.
└─────────────────────────────────────────────────────────────────────────┘\n"
echo -ne "$(blueprint 'View the last 30 commands executed on the system.') \n"
HISTFILE=~/.bash_history
set -o history

history | tail -30


echo -ne "\n$(blueprint 'Gives out the 10 most recently used commands by the user recently.') \n"
echo -ne "$(greenprint 'Times | Number in list  | Command') \n"

history | sort -k2 | uniq -c --skip-fields=1 | sort -r -g | head

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subShowlastusedcommands
  ;;
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subShowlastusedcommands
  ;;
esac
}
sub_subShowDNSconfig() {
  clear
  echo -e "\n
┌───────────────────────    Show DNS Config  .────────────────────┐
  -->  It allows to know if the configuration of the domain names
       and the redirection to some important IP is correct.
└─────────────────────────────────────────────────────────────────┘\n"
echo -ne "$(blueprint 'Display of the dns configured in the system.') \n"
cat /etc/resolv.conf

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu   $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subShowDNSconfig
  ;;
esac
}
sub_subInternetwebtest() {
  clear
  echo -e "\n
┌───────────────────────    Internet web test  .────────────────────┐
  -->  We will try to send three internet packages to the Google
       server and check the internet connectivity if we will be able
       to receive the internet packets from the Google server.
└───────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -e "Command: ping -c 3 google.com \n"
ping -c 3 google.com

echo -ne "\n$(greenprint 'Internet test, connecting to goole.com') \n"
echo -e "Command: wget google.com \n"
wget google.com

echo -ne "\n$(greenprint 'This is the public ip of the server') \n"
curl -s ipecho.net/plain

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu   $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subHealthCheck
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subInternetwebtest
  ;;
esac
}
### Option HealthCheck  ##
subHealthCheck() {
  clear
  echo -e "
┌────────────────────────────   Execute HealthCheck  .────────────────────────────────┐
  -->  Basic Check of the Unix/Linux server
└─────────────────────────────────────────────────────────────────────────────────────┘"
    echo -ne "

  $(blueprint '   Execute HealthCheck')
  $(greenprint '1)')  TOP.
  $(greenprint '2)')  System date and time.
  $(greenprint '3)')  Disk R/W.
  $(greenprint '4)')  Filesystem.
  $(greenprint '5)')  Service status.
  $(greenprint '6)')  Load average.
  $(greenprint '7)')  Top 5 processes by CPU and Memory.
  $(greenprint '8)')  Tcpdump.
  $(greenprint '9)')  Local IP routing table.
  $(greenprint '10)') List of logged users.
  $(greenprint '11)') Log user audit.
  $(greenprint '12)') Show last used commands.
  $(greenprint '13)') Show DNS config.
  $(greenprint '14)') Internet web test.

  $(magentaprint 'm)') Main Menu.
  $(redprint 'e)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        sub_submenuTop
        ;;
    2)
        sub_submenuDateT
        ;;
    3)
        sub_subDiskRW
        ;;
    4)
        sub_subFilesystem
        ;;
    5)
        sub_subServicestatus
        ;;
    6)
        sub_subLoadaverage
        ;;
    7)
        sub_subTop20processesbyCPU
        ;;
    8)
        sub_subTcpdump
        ;;
    9)
        sub_subIProutingtable
        ;;
    10)
        sub_subListofloggedusers
        ;;
    11)
        sub_subLoguseraudit
        ;;
    12)
        sub_subShowlastusedcommands
        ;;
    13)
        sub_subShowDNSconfig
        ;;
    14)
        sub_subInternetwebtest
        ;;
    m|M)
        mainmenu
        ;;
    e|E)
        fn_bye
        ;;
    *)
        fn_fail
        subHealthCheck
        ;;
    esac
}

### SEction NMIS Configuration Consistency
sub_subCheckNMIScode() {
  clear
  echo -e "\n\n
┌───────────────────────    Check NMIS code  .────────────────────┐
  -->  Checking NMIS configuration files for errors
└─────────────────────────────────────────────────────────────────┘"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "$(greenprint 'Wait a moment, we are working') \n"
echo -ne "perl /usr/local/nmis8/admin/check_nmis_code.pl \n"
#nms_code="$(perl /usr/local/nmis8/admin/check_nmis_code.pl | grep -v "ERROR compiling\|Can't locate\|BEGIN failed\|Compilation failed" | tr -d "\t\r" | sed -r '/^\s*$/d')"
perl /usr/local/nmis8/admin/check_nmis_code.pl | grep -v "ERROR compiling\|Can't locate\|BEGIN failed\|cron.d\|models\/Copy\|Missing\|Compilation failed" | tr -d "\t\r" | sed -r '/^\s*$/d'
#echo"$nms_code"
echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'It is recommended to review the mentioned files to solve these errors.') \n"

echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subCheckNMIScode
  ;;
esac
}
sub_subconfigurationbackup() {
  clear
  echo -e "\n
┌─────────────────  Perform a configuration backup  .─────────────┐
  -->  Backup configuration directories in order to preserve all
       the adjustments made by the customer.
└─────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

echo -ne "$(blueprint 'Enter the directory where you want to save your backup:') \n"
echo -ne "$(yellowprint 'Example: /tmp  or  /root') \n"
read var1
echo -ne "$(greenprint 'Performing backup') \n"
BKP_nmis="$(perl /usr/local/nmis9/admin/config_backup_LATAM.pl $var1  )"
echo"$BKP_nmis"
echo -ne "$(greenprint 'Backup successful') \n"
echo -ne "$(yellowprint 'The following directories were backed up:') \n"
echo -ne "
  /
  ├── etc
  │	├─── cron.d
  │	├─── cron.daily
  │	├─── cron.deny
  │	├─── cron.hourly
  │	├─── cron.monthly
  │	├─── crontab
  │	└─── cron.weekly
  └──usr
  	└── local
  		├── nmis9
  		│	├── models-default
  		│	├── models-custom
  		│	├── conf
  		│	├── cgi-bin
  		│	└── menu
  		│	 	 └── css
  		└── omk
  			├── conf
  			├── templates
  			├── lib
  			│ 	└── json
  			└── public
  			 	└── omk
\n"
echo -ne "$(blueprint 'Your backup is here:') \n"
find $var1 -name "nmis-config-backup*" | tail -1

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subconfigurationbackup
  ;;
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subconfigurationbackup
  ;;
esac
}
sub_subComparefile() {
  clear
  echo -e "\n\n
┌──────────────────  Compare file configurations  .───────────────┐
--> Comparison of /install/Config.nmis 
    with /conf/Config.nmis files.
└─────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

echo -ne "$(blueprint 'Automatic comparison of the /nmis9/conf/Config.nmis file') \n"
#perl /usr/local/nmis8/admin/diffconfigs.pl /usr/local/nmis8/install/Config.nmis /usr/local/nmis8/conf
perl /usr/local/nmis9/admin/diffconfigs.pl /usr/local/nmis9/conf-default/Config.nmis /usr/local/nmis9/conf
#echo -ne "\n$(blueprint 'Automatic comparison of the /omk/install-abi2-outofdate/opCommon.json file') \n"
#perl /usr/local/nmis8/admin/diffconfigs.pl /usr/local/omk/install/opCommon.nmis /usr/local/omk/conf
#perl /usr/local/nmis9/admin/diffconfigs.pl /usr/local/omk/install-abi2-outofdate/opCommon.json /usr/local/omk/conf

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'It is recommended to review each of the mentioned differences to detect possible problems in the
configuration of the files.') \n"

echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subComparefile
  ;;
esac
}
sub_subfixperms() {
  clear
  echo -e "\n\n
┌───────────────────── Execute fixperms rutine  .─────────────────┐
  -->  Fixperms
       Correction of permissions on NMIS monitoring system files.
└─────────────────────────────────────────────────────────────────┘\n"


echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

echo -ne "$(greenprint '/usr/local/nmis9/bin/nmis-cli act=fixperms') \n"
/usr/local/nmis9/bin/nmis-cli act=fixperms

echo -e "\nTask completed. \n"
echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subfixperms
  ;;
esac

}
sub_subModelchecking() {
  clear
  echo -e "\n\n
┌───────────────────────── Model checking  ─────────────────────┐
  -->  Model checking
       Validation of syntax and verification of variable length
       within the models.
└───────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "$(greenprint 'perl /usr/local/nmis8/admin/modelcheck.pl') \n"
perl /usr/local/nmis8/admin/modelcheck.pl
echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'It is recommended to review the mentioned files to solve these possible syntax errors.') \n"

echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subModelchecking
  ;;
esac
}
sub_subCrontabchecking() {
  clear
  echo -e "\n\n
┌───────────────────── Crontab checking  ─────────────────┐
  -->  Crontab checking
       View the jobs scheduled in the crontab list.
└───────────────────────────────────────────────────────┘\n"

for user in `cat /etc/passwd | cut -d":" -f1 | grep "nmis\|mongod"`;
do
echo -ne "$(greenprint 'crontab -l -u') $user \n"
crontab -l -u $user;
done

echo -ne "\n$(blueprint 'View the nmis cron file configuration') \n"
echo -ne "$(greenprint 'cat /etc/cron.d/nmis9') \n"
cat /etc/cron.d/nmis9
echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'It is recommended to check the collect parameters as needed for this server:') \n"
echo -ne "$(yellowprint 'abort_after, nmis_maxthreads or maxthreads, sort_due_nodes') \n"


echo -ne "\n$(blueprint 'cron.d directory detail') \n"
cd /etc/cron.d/
ls -l

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'If backups are found in the /etc/cron.d folder, please delete them or move
them to a different folder, as it may conflict with scheduled tasks.') \n"


echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subCrontabchecking
  ;;
esac
}
sub_subVerifyCPANlibraries() {
  clear
  echo -e "\n
┌───────────────────── Verify CPAN libraries  ─────────────────┐
  -->  Checks for CPAN libraries and shows which ones are
       needed so they can be installed if needed.
└──────────────────────────────────────────────────────────────┘\n"
echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

perl /usr/local/nmis8/admin/check_cpan_libraries.pl
d=$(pwd)
rm -f  $d/NMIS-Dependancie*

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'It is recommended to install the missing libraries. Contact your operator.') \n"


echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subVerifyCPANlibraries
  ;;
esac
}
sub_SubLastchangedfiles() {
  clear
  echo -e "\n
┌───────────────────── Configuration fail checking.  ─────────────────┐
  -->  A filtering of the last modified files in different
       NMIS and OMK directories is performed.
  Reviewing the following files is important, since any modification 
  could affect the operation of NMIS and its modules, their 
  customization, and even affect scheduled updates and collects.
└─────────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

echo -ne "\n$(magentaprint 'Searching for last modified files') \n"

echo -ne "\n$(greenprint 'searching in /nmis9/admin/ ') \n"
cd /usr/local/nmis9/admin; ls -lst | head

echo -ne "\n$(greenprint 'searching in /nmis9/bin/ ') \n"
cd /usr/local/nmis9/bin; ls -lst | head

echo -ne "\n$(greenprint 'searching in /nmis9/cgi-bin/ ') \n"
cd /usr/local/nmis9/cgi-bin; ls -lst | head

echo -ne "\n$(greenprint 'searching in /nmis9/conf/ ') \n"
cd /usr/local/nmis9/conf; ls -lst | head

echo -ne "\n$(greenprint 'searching in /nmis9/conf-default/ ') \n"
cd /usr/local/nmis9/conf-default; ls -lst | head

echo -ne "\n$(greenprint 'searching in /nmis9/models-custom/ ') \n"
cd /usr/local/nmis9/models-custom; ls -lst | head

echo -ne "\n$(greenprint 'searching in /nmis9/models-default/ ') \n"
cd /usr/local/nmis9/models-default; ls -lst | head

echo -ne "\n$(greenprint 'searching in /nmis9/lib/ ') \n"
cd /usr/local/nmis9/lib; ls -lst | head

echo -ne "\n$(greenprint 'searching in /omk/conf/ ') \n"
cd /usr/local/omk/conf; ls -lst | head

echo -ne "\n$(greenprint 'searching in /omk/lib/json/ ') \n"
cd /usr/local/omk/lib/json/; ls -lst | head

echo -ne "\n$(greenprint 'searching in /omk/public/omk/ ') \n"
cd /usr/local/omk/public/omk/; ls -lst | head

echo -ne "\n$(greenprint 'searching in /etc/cron.d/ ') \n"
cd /etc/cron.d; ls -lst | head


echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'If any recent file changes are detected, check if this is causing a system problem.') \n"

echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_SubLastchangedfiles
  ;;
esac
}
sub_SubServerPerformanceTuning() {
  clear
  echo -e "\n
┌───────────────────────────────── Configuration Server Performance Tuning.  ─────────────────────────────┐
  -->  There are lots of factors that determine the system health of a server.
The hardware capabilities - CPU, memory or disk - is an important one, but also the server load - number
of devices (Nodes to be polled, updated, audited, synchronised), number of products (NMIS, OAE, opCharts,
opHA - each running different processes), number of concurrent users.

We all want the best performance for a server, and to optimise physical resources, our configuration has to
be fine-grained adjusted.
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"

read -p "Press Enter to continue..."

echo -e "The handling of the omkd_workers will depend on the CPU and memory performance of the server. \n"

echo -ne "\n$(blueprint 'main parameters of the file /nmis9/conf/Config.nmis ') \n"
grep "nmisd_max_workers" /usr/local/nmis9/conf/Config.nmis
grep "nmisd_scheduler_cycle" /usr/local/nmis9/conf/Config.nmis
grep "nmisd_worker_cycle" /usr/local/nmis9/conf/Config.nmis
grep "nmisd_worker_max_cycles" /usr/local/nmis9/conf/Config.nmis
grep "db_query_timeout" /usr/local/nmis9/conf/Config.nmis
grep "max_child_runtime" /usr/local/nmis9/conf/Config.nmis

echo -ne "\n$(blueprint 'main parameters of the file /omk/conf/opCommon.nmis ') \n"
grep "omkd_workers" /usr/local/omk/conf/opCommon.json
grep "omkd_max_requests" /usr/local/omk/conf/opCommon.json
grep "omkd_max_memory" /usr/local/omk/conf/opCommon.json
grep "omkd_max_clients" /usr/local/omk/conf/opCommon.json
grep "omkd_performance_logs" /usr/local/omk/conf/opCommon.json

echo -ne "\n$(blueprint 'main parameters of the file /etc/mongod.conf ') \n"
grep -A 12 "storage" /etc/mongod.conf
echo -ne "\n$(magentaprint 'TIPS TO MongoDB:') \n"
echo -ne "$(redprint 'MongoDB, in its default configuration, will use will use the larger of either 256 MB
or ½ of (ram – 1 GB) for its cache size.
MongoDB cache size can be changed by adding the cacheSizeGB argument to
the /etc/mongod.conf configuration file, as shown below.') \n"


echo -ne "\n\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "$(redprint 'If you require more details on how to configure these parameters, please consult the following link:
https://community.opmantek.com/display/opCommon/Configuration+Options+for+Server+Performance+Tuning') \n"

echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subConfigurationConsistency
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_SubServerPerformanceTuning
  ;;
esac
}
### Option Configuration Consistency  ##
subConfigurationConsistency() {
  clear
  echo -e "
┌──────────────────────   NMIS Configuration Consistency   ───────────────────────────┐
  -->  Options for Reviewing NMIS monitoring system configuration files.
└─────────────────────────────────────────────────────────────────────────────────────┘\n"
    echo -ne "
$(blueprint 'NMIS Configuration Consistency')
$(greenprint '1)') Compare file configurations.
$(greenprint '2)') Execute fixperms rutine.
$(greenprint '3)') Crontab checking.
$(greenprint '4)') Last changed files.
$(greenprint '5)') Server Performance Tuning.

$(magentaprint 'm)') Main Menu
$(redprint 'e)') Exit
Choose an option:  "
    read -r ans
    case $ans in
#    1)
#        sub_subCheckNMIScode
#        ;;
    1)
        sub_subComparefile
        ;;
    2)
        sub_subfixperms
        ;;
    # 4)
    #     sub_subModelchecking
    #     ;;
    3)
        sub_subCrontabchecking
        ;;
    # 6)
    #     sub_subVerifyCPANlibraries
    #     ;;
    4)
        sub_SubLastchangedfiles
        ;;
    5)
        sub_SubServerPerformanceTuning
        ;;
    m|M)
        mainmenu
        ;;
    e|E)
        fn_bye
        ;;
    *)
        fn_fail
        subConfigurationConsistency
        ;;
    esac
}


### SEction Nodes Troubleshooter
sub_subPollingsummaryR() {
  clear
  echo -e "\n
┌───────────────────────    Polling Summary X_late .────────────────────┐
  -->  Ejecute Polling Summary
└───────────────────────────────────────────────────────────────────────┘\n"
x_Late_regex=`grep -Po '(\dx_late\=)\w*' /root/polling_summary_1_$(hostname)`
x_0_late="\dx_late\=0"
if [[ $x_Late_regex =~ $x_0_late ]]; then
  echo -ne "$(greenprint 'At the moment there is no node with the "x_late" parameter.') \n"
else
  echo -ne "$(greenprint 'Filtering of nodes with x_late value. ') \n\n"

echo -e "node                     attempt   status    ping  snmp  policy     delta  snmp avgdel  poll   update  pollmessage"
  cmd_p_summary=`egrep -w 'late|totalNodes|pingDown|totalNodesIncludingRemotes' /root/polling_summary_1_$(hostname)`
  #cmd_polling_summary=`perl /usr/local/nmis8/admin/polling_summary.pl`
  echo -e "\n$cmd_p_summary \n"
  cmd_p_Summary=`egrep -w 'late|totalNodes|pingDown|totalNodesIncludingRemotes' /root/polling_summary_1_$(hostname) > /tmp/polling_Summary_$(hostname)__$(date +%Y%m%d)`
  echo -ne "\n$(greenprint 'We have saved this list of nodes for you,
  you can find the file here:') \n"
  find /tmp/ -name "polling_Summary_*" | tail -1
fi
echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subPollingsummaryR
  ;;
esac
}
sub_subPollingsummary() {
  clear
  echo -e "\n
┌───────────────────────    Polling Summary  .────────────────────┐
  --> Here we can see how many nodes have any late collect, and a
  summary of nodes being collected and not collected.
└─────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."
echo -ne "$(greenprint 'Wait a moment, we are working') \n"
echo -ne "/usr/local/nmis9/admin/polling_summary9.pl \n"

cmd_polling_summary=`perl /usr/local/nmis9/admin/polling_summary9.pl`
cmd_pg_summary=`perl /usr/local/nmis9/admin/polling_summary9.pl > /root/polling_summary_1_$(hostname)`

echo "$cmd_polling_summary"
#$cmd_polling_summary > /root/polling_summary_1_$(hostname)
echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n\n$(yellowprint 'If the values are in the x_late fields, we have to validate the following points:') \n"
echo -ne "$(redprint 'Check for Ping and SNMP response.
Verify the response time of the node and trace.
Verify disk read/write time.
Verify Collect/update duration time.

You can press "l" to perform a filtering to see the nodes with x_late parameters.

You can consult the following information: https://community.opmantek.com/display/NMISES/NMIS+Device+Troubleshooting+Process') \n"



echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back    $(magentaprint 'm)') Main Menu    $(blueprint 'l)') List of X_late nodes    $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subNodesTroubleshooter
  ;;
l|L)
  sub_subPollingsummaryR
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subPollingsummary
  ;;
esac
}
sub_subTraceroute() {
  clear
  echo -e "\n
┌───────────────────────────  Traceroute  .───────────────────────┐
  -->  Traceroute tracks the route packets taken from an IP
       network on their way to a given host.
└─────────────────────────────────────────────────────────────────┘\n"
echo -ne "$(blueprint 'Enter the ip address or hostname:') \n"
echo -ne "$(yellowprint 'Example: 1.1.1.1  or  localhost') \n"
echo -ne "$(redprint 'IP/Hostname:')"; read var2
traceroute $var2

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n$(redprint 'If the node does not respond, contact your operator') \n"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subTraceroute
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subTraceroute
  ;;
esac
}
sub_subMTR() {
  clear
  echo -e "\n
┌────────────────────────────  MTR  .───────────────────────────┐
  -->  As mtr starts, it investigates the network connection
       between the host mtr runs on and HOSTNAME.
└───────────────────────────────────────────────────────────────┘\n"
echo -ne "$(blueprint 'Enter the ip address or hostname:') \n"
echo -ne "$(yellowprint 'Example: 10.10.10.10  or  localhost') \n"
echo -ne "$(redprint 'IP/Hostname:')"; read var3
mtr -r -b $var3

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n$(redprint 'If the node does not respond, contact your operator') \n"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subMTR
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subMTR
  ;;
esac
}
sub_subPing() {
  clear
  echo -e "\n
┌───────────────────── Ping  .─────────────────┐
  -->  Ping uses the ICMP protocol's mandatory
       ECHO_REQUEST datagram to elicit an ICMP
       ECHO_RESPONSE from a host or gateway.
└──────────────────────────────────────────────┘\n"
echo -ne "$(blueprint 'Enter the ip address or hostname:') \n"
echo -ne "$(yellowprint 'Example: 10.10.10.10  or  localhost') \n"
echo -ne "$(redprint 'IP/Hostname:') \n"; read var4
ping -c 4 -b -f $var4

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n$(redprint 'If the node does not respond, contact your operator') \n"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subPing
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subPing
  ;;
esac
}
sub_subSNMPv3() {
  clear
  echo -e "\n
┌───────────────────────── SNMP V3 ───────────────────────┐
  -->  snmpwalk is an SNMP application that uses SNMP
       GETNEXT requests to query a network entity for a
       tree of information.
└───────────────────────────────────────────────────────┘\n"

echo -ne "$(blueprint 'SNMP v3 query structure:') \n"
echo -n "snmpwalk -v3  -u <username> [-a <MD5|SHA>] [-A <authphrase>]  [-x AES|DES] [-X <privaphrase>] -l <noAuthNoPriv|authNoPriv|authPriv> <ipaddress>[:<dest_port>] [oid]"
echo -ne "\n$(greenprint 'ENTER DATA ') \n"




echo -ne "$(magentaprint 'Enter the ip address or hostname:') \n"
echo -ne "$(yellowprint 'Example: 10.10.10.10  or  localhost') \n"
echo -ne "$(redprint 'Enter value of IP/Hostname:')"; read var7
echo -ne "$(redprint 'Note: If you do not have "NMIS Priv Password", type authNoPriv; otherwise, type authPriv|noAuthNoPriv') \n"
echo -ne "$(magentaprint 'Enter value of ("SNMP Priv Password")  -l <noAuthNoPriv|authNoPriv|authPriv>: ')"; read var8
if [[ "$var8" == "authNoPriv" ]]; then
  echo -ne "$(magentaprint 'Enter value of ("SNMP Username")  -u <username>: ')"; read var9
  echo -ne "$(magentaprint 'Enter value of ("SNMP Auth Proto")  -a <MD5|SHA>: ')"; read var10
  echo -ne "$(magentaprint 'Enter value of ("SNMP Auth Password")  -A <authphrase>: ')"; read var11
echo -ne "snmpwalk -v3 -u '$var9' -a '$var10' -A '$var11' -l '$var8' '$var7' system \n"
snmpwalk -v3 -u $var9 -a $var10 -A $var11 -l $var8 $var7 system
else
  echo -ne "$(magentaprint 'Enter value of ("SNMP Username")  -u <username>: ')"; read var9
  echo -ne "$(magentaprint 'Enter value of ("SNMP Auth Proto")  -a <MD5|SHA>: ')"; read var10
  echo -ne "$(magentaprint 'Enter value of ("SNMP Auth Password")  -A <authphrase>: ')"; read var11
  echo -ne "$(magentaprint 'Enter value of ("SNMP Priv Proto")  -x <AES|DES>: ')"; read var12
  echo -ne "$(magentaprint 'Enter value of ("SNMP Priv Password")  -X <privaphrase>: ')"; read var13
echo -ne "snmpwalk -v3 -u '$var9' -a '$var10' -A '$var11' -x '$var12' -X '$var13' -l '$var8' '$var7' system \n"
snmpwalk -v3 -u $var9 -a $var10 -A $var11 -x $var12 -X $var13 -l $var8 $var7 system
fi

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n$(redprint 'If the node does not respond, validate the parameters again to perform
the SNMP query or contact the administrator.') \n"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat     $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subSNMPv3
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subSNMPv3
  ;;
esac

}
sub_subSNMPv2() {
  clear
  echo -e "\n
┌───────────────────────── SNMP V2  ───────────────────────┐
  -->  snmpwalk is an SNMP application that uses SNMP
       GETNEXT requests to query a network entity for a
       tree of information.
└───────────────────────────────────────────────────────┘\n"

echo -ne "$(blueprint 'Enter the ip address or hostname:') \n"
echo -ne "$(yellowprint 'Example: 10.10.10.10  or  localhost') \n"
echo -ne "$(redprint 'IP/Hostname:')";  read var5
echo -ne "$(blueprint 'Enter the SNMP community:') \n"
echo -ne "$(redprint 'Community:')"; read var6
echo -ne "$(greenprint 'snmpwalk -v2c -c') '$var6' '$var5' $(greenprint 'system') \n"
snmpwalk -v2c -c $var6 $var5 system

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n$(redprint 'If the node does not respond, validate the parameters again to perform
the SNMP query or contact the administrator.') \n"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat       $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subSNMPv2
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subSNMPv2
  ;;
esac
}
sub_subSNMP() {
  clear
  echo -e "\n
┌────────────────────────────────── SNMP   ────────────────────────────────┐
  -->  What is snmpwalk?
snmpwalk is the name given to an SNMP application that executes multiple
GETNEXT requests automatically. The SNMP GETNEXT request is used to query
a device and grab SNMP data from a device. The snmpwalk command is used
because it allows the user to chain GETNEXT requests together without having
to enter unique commands for each OID or node within a subtree.
└──────────────────────────────────────────────────────────────────────────┘\n"

echo -ne "$(blueprint 'Select the snmp option to test:') \n"
echo -ne "\n
  $(blueprint '1)') SNMPv1 and SNMPv2
  $(blueprint '2)') SNMPv3

$(magentaprint 'NOTE:')
$(redprint 'For the query to be effective you need to have the parameters,
example: community snmp or
username, MD5|SHA, authphrase, AES|DES, privaphrase, etc, etc.')


  $(blueprint 'b)') Back
  $(magentaprint 'm)') Main Menu
  $(redprint 'e)') Exit
    Choose an option:  "
read -r ans
case $ans in
1)
  sub_subSNMPv2
  ;;
2)
  sub_subSNMPv3
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subSNMP
  ;;
esac
}
sub_subUpdatenodes() {
  clear
  echo -e "\n
┌───────────────────── Update Node  ────────────────────┐
  -->  Allows performing an update of a node on demand
└───────────────────────────────────────────────────────┘ \n"

echo -ne "$(blueprint 'Run update to a node') \n"
echo -ne "$(yellowprint 'Example: localhost') \n"
echo -ne "$(redprint 'Enter node name:')"; read varz3
echo -ne "/usr/local/nmis9/bin/nmis-cli act=schedule job.type=update job.verbosity=1 job.node=$varz3 job.force=1 \n"
/usr/local/nmis9/bin/nmis-cli act=schedule job.type=update job.verbosity=1 job.node=$varz3 job.force=1

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n$(redprint 'If the node does not respond, validate the name or contact the administrator.') \n"

echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subUpdatenodes
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subUpdatenodes
  ;;
esac
}
sub_subCollectnodes() {
  clear
  echo -e "
┌───────────────────── Collect Node  ───────────────────┐
  -->  Allows performing a collect of a node on demand
└───────────────────────────────────────────────────────┘\n"
echo -ne "$(blueprint 'Run collect to a node') \n"
echo -ne "$(yellowprint 'Example: localhost') \n"
echo -ne "$(redprint 'Enter node name:')"; read varz4
echo -ne "/usr/local/nmis9/bin/nmis-cli act=schedule job.type=collect job.verbosity=1 job.node=$varz4 job.force=1 \n"
/usr/local/nmis9/bin/nmis-cli act=schedule job.type=collect job.verbosity=1 job.node=$varz4 job.force=1

echo -ne "\n$(magentaprint 'TIPS TO RESOLVE AN ISSUE:') \n"
echo -ne "\n$(redprint 'If the node does not respond, validate the nomber for node or contact the administrator.') \n"


echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subCollectnodes
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subCollectnodes
  ;;
esac
}
sub_subEventsearch() {
  clear
  echo -e "\n
┌────────────────────────────── Event Search  ──────────────────────────────┐
 --> The main function of the script is to search the log directories of the
  monitoring system, which will make it easier for the user to investigate
  any occurrence or event that has taken place.
└───────────────────────────────────────────────────────────────────────────┘\n"

#echo -ne "$(blueprint 'The script performs an advanced search, which allows the user to enter a
#string or a regex, depending on the case to be investigated as a node/group/event/error.
#This will search all the files in the directories mentioned above, including .tar, .gz
#and .zip files as well.') \n"
#echo -ne "$(yellowprint 'Example:
#search="router1|router2|switch3"
#search="[D|d]own|Ping failed"') \n"
#echo -ne "$(redprint 'Enter the parameter to search for:')"; read varz4
#echo -ne "\n$(yellowprint 'Example:
#varz5="all"
#logs=nmis.log') \n"
#echo -ne "$(redprint 'specifies where to search:')"; read varz5

#echo -ne "sh /usr/local/nmis9/admin/Event.sh \n"
sh /usr/local/nmis9/admin/Event.sh
#perl /usr/local/nmis8/admin/Busqueda.pl "$varz4" $varz5
#busque=`perl /usr/local/nmis8/admin/Busqueda.pl search="$varz4" logs=$varz5`
#echo "$busque"
#search="NMIS is disabled" logs=all
echo -ne "\n
┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
$(blueprint 'r)') Repeat    $(blueprint 'b)') Back
$(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
r|R)
  sub_subEventsearch
  ;;
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subEventsearch
  ;;
esac

}
sub_subNodesbackup() {
  clear
  echo -e "\n
┌───────────────────── Backup to Nodes  ─────────────────┐
  -->  Allows to back up the properties of the nodes
       existing in the monitoring system
└────────────────────────────────────────────────────────┘\n"
echo -ne "$(greenprint 'On-demand backups
Back up the properties of the nodes in NMIS9.
File in Json format.') \n"
#BTIME=`date +%F_%H%M`
#DESTINATION=Nodes_BKP_$BTIME.tar.gz
#SOURCEFOLDER=Nodes.nmis
#cd /root ; tar -C /usr/local/nmis8/conf/ -cpzf $DESTINATION $SOURCEFOLDER #create the backup
echo -ne "/usr/local/nmis9/admin/node_admin.pl act=export file=/tmp/nodes_properties_$(date +%Y%m%d).json"
/usr/local/nmis9/admin/node_admin.pl act=export file=/tmp/nodes_properties_$(date +%Y%m%d).json

echo -ne "\n$(blueprint 'Your backup is here:') \n"
find /tmp -name "nodes_properties_*" | tail -1
#tar -tvf uploadprogress.tar



echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subNodesbackup
  ;;
esac
}
sub_subSupportzip() {
  clear
  echo -e "\n
┌─────────────────────────── Support Zip  ───────────────────────┐
  -->  Allows you to run the NMIS Support Tool and OMK Support
  Tool, which collects all the relevant information about the
  status and configuration of the server in 2 files:
  nmis-support.zip and omk-support.zip, that must be attached in
  case of opening a ticket.
└────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

/usr/local/nmis9/admin/support.pl action=collect maxzipsize=9000000000000000000
sleep 2
/usr/local/omk/bin/support.pl action=collect maxzipsize=9000000000000000000

echo -ne "\n
┌──────────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────────┐
$(blueprint 'b)') Back  $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
b|B)
  subNodesTroubleshooter
  ;;
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  sub_subSupportzip
  ;;
esac
}
### Option Configuration Consistency  ##
subNodesTroubleshooter() {
  clear
  echo -e "\n
┌──────────────────────   Nodes Troubleshooter   ──────────────────────────┐
  -->  Options for Nodes Troubleshooter.
└──────────────────────────────────────────────────────────────────────────┘\n"
    echo -ne "
$(blueprint 'NMIS Configuration Consistency')
$(greenprint '1)') Polling summary Test.
$(greenprint '2)') Traceroute Test.
$(greenprint '3)') MTR Test.
$(greenprint '4)') Ping Test.
$(greenprint '5)') SNMP Test.
$(greenprint '6)') Update nodes Test.
$(greenprint '7)') Collect Node Test.
$(greenprint '8)') Event search.
$(greenprint '9)') Nodes backup.

$(magentaprint 'm)') Main Menu
$(redprint 'e)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        sub_subPollingsummary
        ;;
    2)
        sub_subTraceroute
        ;;
    3)
        sub_subMTR
        ;;
    4)
        sub_subPing
        ;;
    5)
        sub_subSNMP
        ;;
    6)
        sub_subUpdatenodes
        ;;
    7)
        sub_subCollectnodes
        ;;
    8)
        sub_subEventsearch
        ;;
    9)
        sub_subNodesbackup
        ;;
    m|M)
        mainmenu
        ;;
    e|E)
        fn_bye
        ;;
    *)
        fn_fail
        subNodesTroubleshooter
        ;;
    esac
}


### Option Smart Diagnostic
SubSmartDiagnostic() {
  clear
  echo -e "\n
┌──────────────────────   Smart Diagnostic   ──────────────────────────┐
  -->  It allows running smart tests that will allow the operator to
       quickly review the status of the server and diagnose if there
       are any active problems or find details that can be corrected
       in time to avoid them
└──────────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

#create directory
dir1=/tmp/Troubleshooting_Wizard_Files_$(date +%F_%H%M) > /home/z.txt
mkdir -p $dir1
##########################
echo -e "Collecting data from TOP"
echo "Execute HealthCheck  TOP" > $dir1/Top.txt
ctop="$(top -n1 >> $dir1/Top.txt)"
echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
echo -e "Collecting data from Date"
echo -ne "-- Operating System Date --\n" > $dir1/Systemdate.txt
CTL_TIME="$(find /usr/share/  -name "timedatectl" | wc -l)"
      if [[ $CTL_TIME  == 0 ]];
      then
          date >> $dir1/Systemdate.txt
          echo "Time Zone: $(date +'%:z %Z')" >> $dir1/Systemdate.txt
          more /etc/sysconfig/clock >> $dir1/Systemdate.txt
      else
          timedatectl >> $dir1/Systemdate.txt
      fi
echo -ne "\n-- Monitoring system "date" configuration --\n" >> $dir1/Systemdate.txt
more /usr/local/omk/conf/opCommon.json | grep "timezone" >> $dir1/Systemdate.txt
echo -e "\n-- Data and Configuration of the NTP Service --\n" >> $dir1/Systemdate.txt

NTP_TIME=`ps awx | grep 'ntp' |grep -v grep|wc -l`

      if [[ $NTP_TIME == 0 ]];
      then
        echo -ne "The NTP service is not active on this server, \n contact the administrator to verify this status." >> $dir1/Systemdate.txt
      else
          echo -ne " Status Service:\n $(service ntpd status)\n" >> $dir1/Systemdate.txt
          echo -ne " NTP STAT:\n" >> $dir1/Systemdate.txt
          ntpstat >> $dir1/Systemdate.txt
          echo -ne " NTP STAT:\n" >> $dir1/Systemdate.txt
          ntpq -pn >> $dir1/Systemdate.txt
      fi
echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
echo -e "Collecting data from Disk R/W"
echo "--  Disk R/W  --"  > $dir1/Disk_Performance_Check.txt
echo -e "   Test to measure disk write speed \n" >> $dir1/Disk_Performance_Check.txt

         DATE=$(date)
         writeData=$(timeout 10 dd if=/dev/zero of=/usr/local/omkTestFile bs=10M count=1 oflag=direct 2>&1 )
         readData=$(timeout 10 dd if=/usr/local/omkTestFile of=/dev/null 2>&1 )
         timeout 10 rm /usr/local/omkTestFile
         if [ "$writeData" == "" ] ; then
                 writeData='Failed,Failed,Failed'
         fi
         if [ "$readData" == "" ] ; then
                 readData='Failed,Failed,Failed'
         fi
     echo -e "$DATE \n\nWrite: \n$writeData \n\nRead: \n$readData \n" >> $dir1/Disk_Performance_Check.txt

echo -ne "Parameters:
0.0X s to be correct
0.X s, there is a warning (and there would be issue)
X.0 s would be critical (and there would be a problem).\n"  >> $dir1/Disk_Performance_Check.txt

echo -e "\nMonitoring System in/out statistics for devices and partitions."  >> $dir1/Disk_Performance_Check.txt
echo -e "--> 4 queries are made every 5 seconds "  >> $dir1/Disk_Performance_Check.txt
echo -ne "Command:
iostat -x 2 3 \n"  >> $dir1/Disk_Performance_Check.txt

iostat -x 2 3  >> $dir1/Disk_Performance_Check.txt

echo -ne "Parameters:
Using 100% iowait / Utilization indicates that there is a problem and in most
cases a big problem that can even lead to data loss. Essentially, there is a bottleneck
somewhere in the system. Perhaps one of the drives is preparing to die/fail."  >> $dir1/Disk_Performance_Check.txt
echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
echo -e "Collecting data from Filesystem"

echo -ne "-- Show the amount of free disk space on each mounted disk --\n" > $dir1/Filesystem.txt
echo "Command: f -h" >> $dir1/Filesystem.txt
df -h >> $dir1/Filesystem.txt
echo -ne "
TIPS TO RESOLVE AN ISSUE:
If any disk has more than 85% usage, contact the administrator
and inform that the server is low on disk space.\n" >> $dir1/Filesystem.txt

echo -ne "\n-- Displays information of all block devices --\n" >> $dir1/Filesystem.txt

lsblk -o NAME,MAJ:MIN,VENDOR,MODEL,SIZE,TYPE,FSTYPE,RO,MOUNTPOINT,OWNER,GROUP,MODE >> $dir1/Filesystem.txt
echo -ne "\n-- Partition list is sorted by name, integrating unit details, sector size, I/O size. --\n" >> $dir1/Filesystem.txt
fdisk -l  | more >> $dir1/Filesystem.txt

echo -ne "-- Display the amounts of memory used and available on the server --\n" >> $dir1/Filesystem.txt

free -mt >> $dir1/Filesystem.txt
free=$(free -mt | grep Total | awk '{print $4}')
#if [[ "$free" -le 400  ]]; then
if [[ "$free" -le 9000  ]]; then
        ## get top processes consuming system memory and save to temporary file
        #ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
        echo -ne "\nTIPS TO RESOLVE AN ISSUE:
Warning, server memory is running low \nFree memory: $free MB\n" >> $dir1/Filesystem.txt
        echo -ne "Contact the administrator and indicate what is happening" >> $dir1/Filesystem.txt
fi
echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from Service Status"
echo -e "Collecting data from Service Status" > $dir1/ServiceStatus.txt

TIME=$(date +%Y-%m-%d_%T)
omk=`ps awx | grep 'opmantek' |grep -v grep|wc -l`
if [ $omk == 0 ];
    then
      echo -ne "\n\nThe omkd service is stopped, if you want to start it you can run the command: \n" >> $dir1/ServiceStatus.txt
      echo -ne "--> service omkd start or service omkd restart"  >> $dir1/ServiceStatus.txt

    else
      echo -ne "\n service omkd is running"  >> $dir1/ServiceStatus.txt
fi
#Agregar/Omitir servicios segun sea necesario.
declare -a ARRAY=( "mongod " "nmis9d" "httpd" "opchartsd" "opeventsd" "opconfigd" "opflowd" "crond" "snmpd" "iptables"  )
for demon in "${ARRAY[@]}";do
if ps ax | grep -v grep | grep $demon > /dev/null
    then
      echo -ne "\n service $demon  is running"  >> $dir1/ServiceStatus.txt
    else
      echo -ne "\n\n The $demon service is stopped, if you want to start it you can run the command: \n"  >> $dir1/ServiceStatus.txt
      echo -ne " --> service $demon start\n"  >> $dir1/ServiceStatus.txt
      echo -ne " --> service $demon restart\n"  >> $dir1/ServiceStatus.txt
    fi
done

echo -e "\n Check the current status of SELinux \n" >> $dir1/ServiceStatus.txt
 sestatus >> $dir1/ServiceStatus.txt


echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from Load Average" > $dir1/LoadAverage.txt
echo -e "Collecting data from Load Average"

echo -e "Linux load averages are "system load averages" that show the running thread (task)
demand on the system as an average number of running plus waiting threads." >> $dir1/LoadAverage.txt
echo -e "\nCommand: w \n" >> $dir1/LoadAverage.txt
w >> $dir1/LoadAverage.txt
echo -ne "
Some interpretations:

=> If the averages are 0.0, then your system is idle.
=> If the 1 minute average is higher than the 5 or 15 minute averages, then load is increasing.
=> If the 1 minute average is lower than the 5 or 15 minute averages, then load is decreasing.
=> If they are higher than your CPU count, then you might have a performance problem (it depends).\n" >> $dir1/LoadAverage.txt

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from Top 20 processes by CPU and Memory"
echo -e "Collecting data from Top 20 processes by CPU and Memory" > $dir1/Top_processes_CPU_Mem.txt
ps -Aeo user,pid,ppid,%mem,%cpu,stat,start,time,cmd --sort=-%cpu | head -n 21 >> $dir1/Top_processes_CPU_Mem.txt

echo -ne "\nDetails CPU:\n" >> $dir1/Top_processes_CPU_Mem.txt
lscpu >> $dir1/Top_processes_CPU_Mem.txt

ps -Aeo user,pid,ppid,%mem,%cpu,stat,start,time,cmd --sort=-%mem | head -n 21 >> $dir1/Top_processes_CPU_Mem.txt
echo -ne "\nDetails Memory\n" >> $dir1/Top_processes_CPU_Mem.txt
lsmem >> $dir1/Top_processes_CPU_Mem.txt

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from IP routing table"

echo -ne "Display routing table in full\n" > $dir1/IP_Routing.txt
route -n >> $dir1/IP_Routing.txt

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from List of logged users"

echo -ne "Shows information about the users currently on the machine, and their processes. \n" > $dir1/List_of_logged_users.txt
echo -e "\n" >> $dir1/List_of_logged_users.txt
w >> $dir1/List_of_logged_users.txt
echo -e "\n" >> $dir1/List_of_logged_users.txt
who -a >> $dir1/List_of_logged_users.txt

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from Log user audits"
echo -e "Collecting data from Log user audits" > $dir1/Log_user_audits.txt

echo -ne "Shows failed login attempts. \n" >> $dir1/Log_user_audits.txt
au=$(ausearch --message USER_LOGIN --success no --interpret 2>/dev/null )
echo "$au" >> $dir1/Log_user_audits.txt
echo -ne "\nShows all failed system calls from yesterday up until now. \n" >> $dir1/Log_user_audits.txt
ausearch --start yesterday --end now -m SYSCALL -sv no -i >> $dir1/Log_user_audits.txt
echo -ne "\nReview of the /var/log/messages file for errors or failures \n" >> $dir1/Log_user_audits.txt
tail -n 100 /var/log/messages | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 20 >> $dir1/Log_user_audits.txt
echo -ne "\nReview of the /var/log/secure file for errors or failures \n" >> $dir1/Log_user_audits.txt
tail -n 100 /var/log/secure | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 20 >> $dir1/Log_user_audits.txt
echo -ne "\nReview of the /var/log/cron file for errors or failures \n"  >> $dir1/Log_user_audits.txt
tail -n 100 /var/log/cron | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 20 >> $dir1/Log_user_audits.txt
echo -ne "\nReview of the /var/log/dmesg file for errors or failures \n" >> $dir1/Log_user_audits.txt
tail -n 100 /var/log/dmesg | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 20 >> $dir1/Log_user_audits.txt
echo -ne "\nReview of the /var/log/boot.log file for errors or failures \n" >> $dir1/Log_user_audits.txt
tail -n 100 /var/log/boot.log | grep -i "error\|warn\|alert\|kernel\|panic\|user\|kill" | head -n 20 >> $dir1/Log_user_audits.txt


echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from History"
export HISTFILE

cat "$HOME/.bash_history" > $dir1/history.txt
#echo "$h" > $dir1/History.txt
#h=$(tail -n 200 $HISTFILE > $dir1/History.txt)
echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from DNS Config"

cat /etc/resolv.conf >  $dir1/DNS_Config.txt

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from Internet web test"

echo -e "Command: ping -c 3 google.com \n" > $dir1/TestInternet.txt
 ping1=$(ping -c 3 google.com )
 echo "$ping1" >> $dir1/TestInternet.txt

echo -ne "\nInternet test, connecting to goole.com \n" >> $dir1/TestInternet.txt
echo -e "Command: wget google.com \n" >> $dir1/TestInternet.txt
w1=$(wget google.com 2>&1)
echo "$w1" >> $dir1/TestInternet.txt

echo -ne "\nThis is the public ip of the server \n" >> $dir1/TestInternet.txt
curl -s ipecho.net/plain >> $dir1/TestInternet.txt


echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from polling_summary"

perl /usr/local/nmis9/admin/polling_summary9.pl > $dir1/polling_summary.txt

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from Perform a configuration backup"

perl /usr/local/nmis9/admin/config_backup_LATAM.pl /tmp  > /dev/null

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from fixperms"

perl /usr/local/nmis9/bin/nmis-cli act=fixperms > /dev/null

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
# echo -e "Collecting data from Support Zip"
#
# /usr/local/nmis8/admin/support.pl action=collect  maxzipsize=900000 > /dev/null
#
# echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo -e "Collecting data from version RRD and Mongo"
echo -e "Collecting data from version RRD and Mongo" > $dir1/version_RRD_and_Mongo.txt

rrdtool --version >> $dir1/version_RRD_and_Mongo.txt
mongo -version >> $dir1/version_RRD_and_Mongo.txt

echo -ne "$(greenprint '......................................... Completed  ✓ ') \n\n"
##########################
##########################
echo "$dir1" | sed 's/\/tmp\///' > /home/z.txt
dir2=$(more /home/z.txt)
#more /home/z.txt
#tar -C /tmp -czvf $dir2.tar.gz $dir1 #> /dev/null #| mv $dir2.tar.gz /tmp
tar -C /tmp -czvf $dir2.tar.gz $dir2 > /dev/null #| mv $dir2.tar.gz /tmp
mv $dir2* /tmp > /dev/null
echo -ne "\n$(blueprint 'Your tar.gz file of the Troubleshooting Wizard is here:') \n"
echo -ne "\n$(magentaprint 'Status and details of the operating system and NMIS')\n"
find /tmp -name "$dir2.tar.gz" | tail -1

##########################
echo -ne "\n$(magentaprint 'Directory backup .tar file')\n"
#find /tmp -name "Troubleshooting_Wizard_backup-*" | tail -1
find /tmp -type f -mtime -1 | grep "Troubleshooting_Wizard_backup-$(date +%F-%H%M)" | tail -1

##########################
#pwd
cd /home/test
rm -rf index.ht*
cd /tmp
rm -rf $dir2
#
rm -f  /home/z.txt

echo -e "\nOperation completed \n"
#echo -ne "$(blueprint 'Your backup is here:') \n"
echo -ne "$(redprint 'This .tar.gz file must be sent as an attachment in the ticket created at support@opmantek.com.')'"

echo -ne "\n
┌──────────   $(yellowprint 'OPTIONS MENU')  ─────────────┐
 $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  SubSmartDiagnostic
  ;;
esac
}


### Option Create System Backup  ##
SubCreateSystemBackupFile() {
  clear
  echo -e "\n
┌─────────────────  Perform a configuration backup  .─────────────┐
  -->  Backup configuration directories in order to preserve all
       the adjustments made by the customer.
└─────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

echo -ne "$(blueprint 'Enter the directory where you want to save your backup:') \n"
echo -ne "$(yellowprint 'Example: /tmp  or  /root') \n"
read var1
echo -ne "$(greenprint 'Performing backup') \n"
BKP_nmis="$(perl /usr/local/nmis9/admin/config_backup_LATAM.pl $var1  )"
echo"$BKP_nmis"
echo -ne "$(greenprint 'Backup successful') \n"
echo -ne "$(yellowprint 'The following directories were backed up:') \n"
echo -ne "
  /
  ├── etc
  │	├─── cron.d
  │	├─── cron.daily
  │	├─── cron.deny
  │	├─── cron.hourly
  │	├─── cron.monthly
  │	├─── crontab
  │	└─── cron.weekly
  └──usr
  	└── local
  		├── NMIS9
  		│	├── models-default
  		│	├── models-custom
  		│	├── conf
  		│	├── cgi-bin
  		│	└── menu
  		│	 	 └── css
  		└── omk
  			├── conf
  			├── templates
  			├── lib
  			│ 	└── json
  			└── public
  			 	└── omk
\n"
echo -ne "$(blueprint 'Your backup is here:') \n"
#find $var1 -name "Troubleshooting_Wizard_backup*" | tail -1
find $var1 -type f -mtime -1 | grep "Troubleshooting_Wizard_backup-$(date +%F-%H%M)" | tail -1

  echo -ne "\n
  ┌────────────────────────   $(yellowprint 'OPTIONS MENU')  ────────────────────────┐
  $(blueprint 'r)') Repeat    $(magentaprint 'm)') Main Menu     $(redprint 'e)') Exit
  Choose an option:  "
  read -r ans
  case $ans in
  r|R)
  SubCreateSystemBackupFile
  ;;
  m|M)
  mainmenu
  ;;
  e|E)
  fn_bye
  ;;
  *)
  fn_fail
  SubCreateSystemBackupFile
  ;;
  esac

}


### Option Execute Support Automation Tool
SubSupportAutomationTool() {
  clear
  echo -e "\n
┌─────────────────────────── Support Zip  ─────────────────────────┐
  -->  Allows you to run the NMIS Support Tool and OMK Support
       Tool, which collects all the relevant information about
       the status and configuration of the server in 2 files:
       nmis-support.zip and omk-support.zip, that must be attached
       in case of opening a ticket.
└──────────────────────────────────────────────────────────────────┘\n"

echo -e "The test will start soon. \n"
read -p "Press Enter to continue..."

/usr/local/nmis9/admin/support.pl action=collect maxzipsize=9000000000000000000
sleep 2
/usr/local/omk/bin/support.pl action=collect maxzipsize=9000000000000000000


echo -ne "\n
┌──────────   $(yellowprint 'OPTIONS MENU')  ─────────────┐
 $(magentaprint 'm)') Main Menu  $(redprint 'e)') Exit
Choose an option:  "
read -r ans
case $ans in
m|M)
  mainmenu
  ;;
e|E)
  fn_bye
  ;;
*)
  fn_fail
  SubSupportAutomationTool
  ;;
esac
}


mainmenu() {
clear

echo -ne "\nWelcome to the Troubleshooting Wizard NMIS9.\n"

echo -ne "
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░ ┌────────────────────────────────────────────────────────────┐ ░░
  _____  _             _  __        __                  
 |  ___|(_) _ __  ___ | |_\ \      / /__ _ __   __ ___  
 | |_   | || °__|/ __|| __|\ \ /\ / // _| |\ \ / // _ \ 
 |  _|  | || |   \__ \| |_  \ V  V /| (_| | \ V /|  __/ 
 |_|    |_||_|   |___/ \__|  \_/\_/  \__,_|  \_/  \___| 
                             _                          
                           _| |_                        
                          |_   _|                       
   ___                      |_|          _         _    
  / _ \  _ __   _ __ ___    __ _  _ __  | |_  ___ | | __
 | | | || ._ \ | ._ . _ \  / _! || ._ \ | __|/ _ \| |/ /
 | |_| || |_) || | | | | || (_| || | | || |_|  __/|   < 
  \___/ | .__/ |_| |_| |_| \__,_||_| |_| \__|\___||_|\_\.
        |_|
░░ └──────────────────────────────────────────────────────────┘ ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
\n"
echo -ne "Consult the manuals if you require more details about the tool.

Spanish: https://community.opmantek.com/display/NMISES/Manual+descriptivo+del+Troubleshooting+Wizard+para+NMIS+9
English: https://community.opmantek.com/display/NMISES/Troubleshooting+Wizard+descriptive+Manual+for+NMIS+9
\n\n"
read -p "Press Enter to continue..."
clear
echo -ne "
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░ ┌───────────────────────────────────────────────────────────────┐ ░░
░░ │               Troubleshooting Wizard NMIS9 OPMANTEK           │ ░░
░░ │    Welcome to the Troubleshooting tool, here you will find    │ ░░
░░ │        some useful options for analyzing, checking and        │ ░░
░░ │              diagnosing the NMIS monitoring system.           │ ░░
░░ └───────────────────────────────────────────────────────────────┘ ░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
┌─────────────────────────Details of Operating System.────────────────────────────────┐
⇒ $(cat /etc/*release* | head -2) \n
                    ─ $(hostname) ── $(date)
-------------------------------------------------------------------------------------
$(vmstat -S M)
└─────────────────────────────────────────────────────────────────────────────────────┘\n
$(magentaprint 'Main Menu')
$(greenprint '1)')  Execute Manual HealthCheck.
$(greenprint '2)')  Review NMIS Configuration Consistency.
$(greenprint '3)')  Nodes Troubleshooter.
$(greenprint '4)')  Execute Smart Diagnostics.
$(greenprint '5)')  Create System Backup File.
$(greenprint '6)')  Execute Support Automation Tool.

$(redprint 'e)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        subHealthCheck
        ;;
    2)
        subConfigurationConsistency
        ;;
    3)
        subNodesTroubleshooter
        ;;
    4)
        SubSmartDiagnostic
        ;;
    5)
        SubCreateSystemBackupFile
        ;;
    6)
        SubSupportAutomationTool
        ;;
    e|E)
        fn_bye
        ;;
    *)
        fn_fail
        mainmenu
        ;;
    esac
}

mainmenu
