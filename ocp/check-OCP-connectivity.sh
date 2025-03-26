#!/bin/bash
#Author: Renan Cirello de Sá
#E-mail: rcirello@gmail.com
#Objective: Check connectivity

#############################
### Text Formatting Variables
#############################
R="\033[0;31m"
G="\033[0;32m"
Y="\033[1;33m"
W="\033[0;37m"
RST="\033[0m"
OK="${G}[CONNECTION ESTABLISHED]${RST}"
ERR="${R}[CONNECTION ERROR]${RST}"
INF="${Y}[CONNECTING]${RST}"

CONNECTION_TIMEOUT=2
CONNECTIONS_TO_CHECK=(
  "www.google.com.br:445"
  "www.google.com.br:443"
  "192.168.5.221:9091"
  "192.168.5.221:22"
)
OVERALL_ERROR_CODE=0
TRAILING_CHARS_SIZE=$(echo -ne ${OK} | wc -c)

fn_ExecStatus(){
  local execStatus="${1}"
  if [ ${execStatus} == 0 ]; then
    echo -e ${OK}
  else
    echo -e ${ERR}
  fi
}

fn_PrintLine(){
  local status_string="${1}"
  local msg_string="${2}"
  local status_size=$(echo -ne "${status_string}" | wc -c)
  local trailing_chars=$(awk "BEGIN{ for(c=0;c<$((${TRAILING_CHARS_SIZE}-${status_size}));c++) printf \"-\"}")
  echo -ne "* ${status_string} ${trailing_chars}-> ${msg_string}\033[0K\r"
}


echo "Checking ${#CONNECTIONS_TO_CHECK[@]} connections:"
for connection in ${CONNECTIONS_TO_CHECK[@]}
do
  fn_PrintLine "${INF}" "${W}${connection}${RST}."
  connection_test=$(timeout ${CONNECTION_TIMEOUT} curl -v telnet://${connection} 2>&1)
  echo ${connection_test} | grep -qi "connected to $(echo ${connection} | cut -d ':' -f1).*port $(echo ${connection} | cut -d':' -f2)"
  error_code=${?}
  OVERALL_ERROR_CODE=$(( $OVERALL_ERROR_CODE + $error_code ))
  fn_PrintLine "$(fn_ExecStatus ${error_code})" "${W}${connection}${RST}."
  echo
done

echo -n "Overall Status: "
fn_ExecStatus ${OVERALL_ERROR_CODE}

if [ ${OVERALL_ERROR_CODE} -eq 0 ]; then
  exit 0
else
  exit 1
fi

