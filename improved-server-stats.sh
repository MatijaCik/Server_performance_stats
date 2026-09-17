#!/bin/bash

while true; do

read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

sleep 1

read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice < /proc/stat

idle_delta=$((idle2 - idle))

total_delta=$((user2 - user + nice2 - nice + system2 - system + idle2 - idle + iowait2 - iowait + irq2 - irq + softirq2 - softirq + steal2 - steal))

usage=$(awk -v idle="$idle_delta" -v total="$total_delta" 'BEGIN {
printf "%.2f", (1 - idle / total) * 100 }')


read -r _ total used free shared cache available < <(free | grep '^Mem:')

free_mem=$(awk -v available="$available" -v total="$total" 'BEGIN {
printf "%.2f", available / total * 100 }')

used_mem=$(awk -v used="$used" -v total="$total" 'BEGIN {
printf "%.2f", used / total * 100 }')

read -r _ size used avail use_perc mounted < <(df -h / | tail -1)

used_disk="${use_perc%\%}"

free_disk=$(awk -v used="$used_disk" 'BEGIN {
printf "%.2f", 100 - used }')

top_cpu=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6)
top_mem=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 6)

name=$(whoami)

uptime_users=$(w)
running_os=$(grep -E '^(VERSION|NAME)=' /etc/os-release)
clear
RED='\033[0;31m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"
printf "Hello user ${RED}%s${NC}\n\n"        "$name"
echo -e "--------------------------------------\n           ${RED}SERVER STATS${NC}  \n--------------------------------------"
#echo -e "--------------------------------------\n           ${RED} \e[5mSERVER STATS${NC} \e[25m \n--------------------------------------"
printf "Running OS:\n%s\n\n" "$running_os"
printf "Uptime_and_users: \n %s\n\n" "$uptime_users"
printf "CPU Usage:     %6s%%\n" "$usage"
printf "Free memory:   %6s%%\n" "$free_mem"
printf "Used memory:   %6s%%\n" "$used_mem"
printf "Used disk:     %6s%%\n" "$used_disk"
printf "Free disk:     %6s%%\n" "$free_disk"

echo
echo "Top 5 CPU processes"
echo "$top_cpu"
echo
echo "Top 5 Memory processes"
echo "$top_mem"

done
