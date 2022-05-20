#!/bin/bash

echo -ne "The script performs an advanced search, hich allows the user to enter a
string or a regex, depending on the case to be investigated as a node/group/event/error.
This will search all the files in the directories mentioned above, including .tar, .gz
and .zip files as well. \n"
echo -ne "Example:
search=router1*3
search=Proactive Interface Input Utilisation.*GigabitEthernet0/0/1 \n"
read -p "Enter string to search: " VAR1

echo -ne "\n Example:
logs=nmis.log
logs=event.log
logs=all \n"
echo -ne "\nSpecifies where to search: "; read VAR2
echo -ne "\n"
#Agregar/Omitir servicios segun sea necesario.
declare -a ARRAY=( "auth.log" "event.log" "fping.log" "nmis.log")
for log1 in "${ARRAY[@]}";do
if [[ "$VAR2" == "$log1" ]];
    then
        find /usr/local/nmis9/logs/ -name "$log1*" -print0 && echo -ne "\n" && find /usr/local/nmis9/logs/ -name "$log1*" -print0 | xargs -0 zgrep "$VAR1"
        echo -ne "\n"
    else
        declare -a ARRAY=( "admin.log" "audit.log" "opData.log" "auth.log" "baseline.log" "opEvents.log" "common.log" "opHA-cli.log" "omkd_out.log" "opHA.log" "opCharts.log" "opLicense_cli.log" "opConfig-cli.log" "oprbac_admin.log" "opConfig.log" "opReports.log" "opDaemon.log" )
        for log2 in "${ARRAY[@]}";do
        if [[ "$VAR2" == "$log2" ]];
            then
              #find /usr/local/omk/log/ -name "$log2*" -print0 && echo -ne "\n" &&
              find /usr/local/omk/log/ -name "$log2*" -print0 | xargs -0 zgrep "$VAR1"
              echo -ne "\n"
        fi
        done
    fi
done

if [[ $VAR2 == "all" ]]; then
  declare -a ARRAY=( "auth.log" "event.log" "fping.log" "nmis.log")
    for log3 in "${ARRAY[@]}";do
      find /usr/local/nmis9/logs/ -name "$log3*" -print0 && echo -ne "\n" && find /usr/local/nmis9/logs/ -name "$log3*" -print0 | xargs -0 zgrep "$VAR1"
      #find /usr/local/nmis8/logs/ -name "$log3*" -print0 | xargs -0 zgrep "$VAR1"
      echo -ne "\n"
    done
  #exit
else
  echo -ne "El nombre del archivo no es correcto, favor de validar."
  exit
fi

if [[ $VAR2 == "all" ]]; then
  declare -a ARRAY=( "admin.log" "audit.log" "opData.log" "auth.log" "baseline.log" "opEvents.log" "common.log" "opHA-cli.log" "omkd_out.log" "opHA.log" "opCharts.log" "opLicense_cli.log" "opConfig-cli.log" "oprbac_admin.log" "opConfig.log" "opReports.log" "opDaemon.log" )
    for log4 in "${ARRAY[@]}";do
      #find /usr/local/omk/log/ -name "$log4*" -print0 && echo -ne "\n" && find /usr/local/omk/log/ -name "$log4*" -print0 | xargs -0 zgrep "$VAR1"
      find /usr/local/omk/log/ -name "$log4*" -print0 | xargs -0 zgrep "$VAR1"
    done
  #exit
else
  echo -ne "El nombre del archivo no es correcto, favor de validar."
  exit
fi
