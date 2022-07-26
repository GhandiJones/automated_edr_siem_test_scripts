#!/bin/bash
set -euxo pipefail

function header () {
  echo "===== $1 ====="
}

INFO=/var/log/lab-x-test-info.log
DEBUG=/var/log/lab-x-test-debug.log

# Create Log Files
printf '' > $INFO > $DEBUG

# Tail the info logfile as a background process so the contents of the
# info logfile are output to stdout.
tail -f $INFO &

# Set an EXIT trap to ensure your background process is
# cleaned-up when the script exits
trap "pkill -P $$" EXIT

# Redirect both stdout and stderr to write to the debug logfile
exec 1>>$DEBUG 2>>$DEBUG

# Tests

# EICAR Test
header "EICAR Tests" | tee -a $INFO
MAL_NAMES=("evil" "not-so-malware" "friendly-ish" "unholy" "foul" "naz-tea" "daemonic")
SIZE=${#MAL_NAMES[@]}
EICAR_DIR=/nothing/to/see/here
sudo mkdir -p $EICAR_DIR
# Single download
header "Test #1 - Download Eicar" | tee -a $INFO
curl www.eicar.org/download/eicar.com.txt > eicar.com.txt
# Download mass dump
header "Test #2 - Mass Eicar file download" | tee -a $INFO
for i in {1..5}; do arr_index=$(($RANDOM % $SIZE)); curl www.eicar.org/download/eicar.com.txt > "$EICAR_DIR/${MAL_NAMES[$arr_index]}-${i}.txt"; sleep 0.01; done
# Crafted mass dump
header "Test #2 - Mass Eicar file creation" | tee -a $INFO
for i in {1..5}; do arr_index=$(($RANDOM % $SIZE)); echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > "$EICAR_DIR/${MAL_NAMES[$arr_index]}-${i}.txt"; sleep 0.01; done

# MITRE Reference https://attack.mitre.org/techniques/T1003/008/
# Tests from https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1003.008/T1003.008.md
header "T1003.008 - /etc/passwd and /etc/shadow" | tee -a $INFO
output_file=/tmp/T1003.008.txt

header "Test #1 - Access /etc/shadow (Local)" | tee -a $INFO
sudo cat /etc/shadow > $output_file
cat $output_file

header "Test #2 - Access /etc/passwd (Local)" | tee -a $INFO
cat /etc/passwd > $output_file
cat $output_file

header "Test #3 - Access /etc/{shadow,passwd} with a standard bin that's not cat" | tee -a $INFO
#sudo echo -e $(e /etc/passwd;p;e /etc/shadow;p) > $output_file

header "Test #4 - Access /etc/{shadow,passwd} with shell builtins" | tee -a $INFO
function testcat(){ echo "$(< $1)"; }
testcat /etc/passwd > $output_file
testcat /etc/shadow > $output_file

header "Cleanup of $output_file" | tee -a $INFO
sudo rm -f $output_file
