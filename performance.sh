#!/bin/bash


logFile="log/performance_log.txt"
date=$(date '+%Y:%m:%d | %H:%M:%S')
set -a # automatically export all variables
source .env
set +a
# Token=$TELE_TOKEN
# ID_Admin=$ID_ADMIN

SendNotification() {
    # url="https://api.telegram.org/bot$TELE_TOKEN/sendMessage\?chat_id\=$ID_ADMIN\&text\=$1"
    # x="-X"
    # query=`curl $x POST $url`
    curl -s --data "text=$1" --data "chat_id=$ID_ADMIN" 'https://api.telegram.org/bot'$TELE_TOKEN'/sendMessage' >> /dev/null
    # echo $query
}

WriteIntoFile() {
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
        SendNotification "$date: CPU: $cpu_usage%, RAM: $ram_usage_percent%,DISK: $MemUsagePercent%"
    fi
}


# if use cronjob
Performance

# if not use cronjob
# while true
# do 
#     Performance
#     sleep 3600
# done
