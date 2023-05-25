#!/bin/bash
while true
do

wget emsc-csem.org/Earthquake
id=$(cat Earthquake | grep -m 1 "ligne2 normal" | awk '{print $2}' | sed 's/id="//;s/",$//;s/"$//')
rm Earthquake
wget https://www.emsc-csem.org/Earthquake/earthquake.php?id=$id
info=$(cat earthquake.php?id=$id | grep -F 'property="og:title"' | awk '{for(i=4;i<=NF-2;i++) {gsub(/["-]/, "", $i); printf("%s ",$i)}; gsub(/["-]/, "", $(NF-1)); print $(NF-1)}')
location=$(cat earthquake.php?id=$id | grep -o '<td class="point">Location</td><td class="point2">[^<]*</td>' | sed 's/<[^>]*>//g' | sed 's/Location//')
rm earthquake.php?id=$id
last_info=$(cat file.txt | head -n 1)
magnitude=$(echo "$info" | grep -oE 'Magnitude [0-9.]+')
mag2=$(echo $magnitude | cut -d' ' -f2-)
time=$(echo "$info" | grep -oP '[0-9]{4} [A-Z][a-z]{2} [0-9]{2}, [0-9]{2}:[0-9]{2}:[0-9]{2} UTC')
place=$(echo "$info" | sed "s/$magnitude//; s/$time//; s/^[[:space:]]*//; s/[[:space:]]*$//")
data="🌍 **Earthquake Alert!**\n\nMagnitude: $mag2\nLocation: $place\nDate and Time: $time\nCoordinates: $location\n\nStay safe and take necessary precautions if you are in the affected area."

if [ "$info" != "$last_info" ]; then
    echo "$info" > file.txt
        curl -X POST -H "Content-Type: application/json" -d "{\"content\":\"$data\"}" "Here-Your-webhook"

fi

sleep 5

done
