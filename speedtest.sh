#!/usr/bin/env bash

set -e

CACHE_FILE=/var/log/zabbix/speedtest.log
LOCK_FILE=/tmp/speedtest.lock

run_speedtest() {
    cd "$(readlink -f "$(dirname "$0")")" || exit 9

    # Lock
    if [[ -e "$LOCK_FILE" ]]
    then
        echo "A speedtest is already running" >&2
        exit 2
    fi
    touch "$LOCK_FILE"
    trap "rm -rf $LOCK_FILE" EXIT HUP INT QUIT PIPE TERM

    local output date location_id location ping download upload distance local_ip city
    local download_mb upload_mb

    output=$(python /usr/local/bin/speedtest --server 20531 --csv --csv-delimiter '|')

    # Debug
    # output=6889|Twin Valley Communications|Miltonvale, KS|2019-02-15T00:30:00.344076Z|76.63434604957892|26.276|222487444.93646407|32353150.5438985||70.179.147.69
    # sleep 10

    echo "Output: $output"

    # Extract fields
    location_id=$(echo "$output" | cut -f1 -d '|')
    location=$(echo "$output" | cut -f2 -d '|' | sed 's/^"\(.*\)"$/\1/g')
    city=$(echo "$output" | cut -f3 -d '|')
    date=$(echo "$output" | cut -f4 -d '|')
	distance=$(echo "$output" | cut -f5 -d '|')
	ping=$(echo "$output" | cut -f6 -d '|')
    download=$(echo "$output" | cut -f7 -d '|')
    upload=$(echo "$output" | cut -f8 -d '|')
    local_ip=$(echo "$output" | cut -f10 -d '|')

    # Convert to MBit/s
    download_mb=$(echo "$download" | awk '{ printf("%.2f\n", $1 / 1048576) }')
    upload_mb=$(echo "$upload" | awk '{ printf("%.2f\n", $1 / 1048576) }')

    {
        echo "Date: $date"
        echo "Server: $location - $city[${location_id}]"
        echo "Distance: $distance"
        echo "Ping: $ping ms"
        echo "Download: $download bit/s"
        echo "Upload: $upload bit/s"
        echo "Download (MB): $download_mb Mbit/s"
        echo "Upload (MB): $upload_mb Mbit/s"
        echo "Local IP: $local_ip"
    } > "$CACHE_FILE"

    # Make sure to remove the lock file (may be redundant)
    rm -rf "$LOCK_FILE"
}

case "$1" in
    -c|--cached)
        cat "$CACHE_FILE"
        ;;
    -u|--upload)
        awk '/Upload \(MB\)/ { print $3 }' "$CACHE_FILE"
        ;;
    -d|--download)
        awk '/Download \(MB\)/ { print $3 }' "$CACHE_FILE"
        ;;
    -p|--ping)
        awk '/Ping/ { print $2 }' "$CACHE_FILE"
        ;;
    -s|--server)
        awk '/Server/ { print }' "$CACHE_FILE"
        ;;
    -f|--force)
        rm -rf "$LOCK_FILE"
        run_speedtest
        ;;
    *)
        run_speedtest
        ;;
esac