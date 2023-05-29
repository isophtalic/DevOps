#!/bin/bash

logFile="log/performance_log.txt"

WriteIntoFile() {
    date=$(date '+%Y:%m:%d | %H:%M:%S')
    Notification="$date: CPU: $1%, RAM: $2%,DISK: $3%"
    if [ -e $logFile ] && [ -r $logFile ] && [ -w $logFile ]
    then
        echo $Notification >> $logFile
    fi
}

Performance() {
    # Handle Mem
    Buffcache=$(free -m | awk '/Mem/ {print $6}')
    FreeMem=$(free -m | awk '/Mem/ {print $4}')
    AvailableMem=$(free -m | awk '/Mem/ {print $7}')
    TotalMem=$(free -m | awk '/Mem/ {print $2}')
    TotalUsedMem=`expr $TotalMem - $AvailableMem`
    MemUsagePercent=$(bc <<< "scale=2; $TotalUsedMem*100 / $TotalMem")

    # handle CPU
    top_output=$(top -bn1 | grep "Cpu(s)")

    # Extract the CPU usage percentage from the retrieved line
    cpu_usage=$(echo "$top_output" | awk '{print $2 + $4}' | awk '{sub (",", ".")} 1 ')


    # handle RAM
    ram_info=$(free -m)
    # Extract the used RAM value
    used_ram=$(echo "$ram_info" | awk '/^Mem:/ {print $3}')
    total_ram=$(echo "$ram_info" | awk '/^Mem:/ {print $2}')
    ram_usage_percent=$(awk "BEGIN { printf \"%.2f\", ${used_ram} / ${total_ram} * 100 }" | awk '{sub (",", ".")} 1 ')

    compareMEM=$(echo "$MemUsagePercent >= 90" | bc -l)
    compareCPU=$(echo "$cpu_usage >= 90" | bc -l)
    compareRAM=$(echo "$ram_usage_percent >= 90" | bc -l)

    if [ "$compareMEM" -eq 1 ] || [ "$compareCPU" -eq 1 ] || [ "$compareRAM" -eq 1 ]
    then
        WriteIntoFile $cpu_usage $ram_usage_percent $MemUsagePercent 
    fi
}

# Performance
# set -a # automatically export all variables
# source .env
# set +a
# echo "$EMAIL_SENDER, $EMAIL_PASSWORD, $EMAIL_RECEIVER"
# SERVER="smtp.gmail.com"
# FROM="$EMAIL_SENDER"
# PASSWORD="$EMAIL_PASSWORD"
# TO="$EMAIL_RECEIVER"
# SUBJ="Some subject"
# MESSAGE="$1, $2"
# CHARSET="utf-8"

recipient=$EMAIL_RECEIVER
subject="Test Email"
body="This is a test email sent using ssmtp."

# Construct the email message
message="Subject: $subject\n\n$body"

# Send the email using ssmtp
echo -e "$message" | ssmtp "$recipient"