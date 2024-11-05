#!/bin/bash

# This script is a workaround for a bug in the Linux kernel that causes
# stale NDP entries to be left in the kernel's neighbor table. This can
# cause packets to be dropped when the kernel tries to send them to the
# stale entry.

function ping() {
    ping6 -c 1 -W .5 -q "$ipv6" 1>/dev/null 2>&1
}

function remove_neighbor() {
    echo "Removing neighbor entry for $ipv6"
    ip -6 neigh flush "$ipv6" 1>/dev/null 2>&1
}

function main() {
    local ipv6
    local device
    local count

    count=${2:-0}
    if [ "$count" -gt 2 ]; then
        echo "Error: too many attempts to remove neighbor entry"
        exit 1
    fi

    # Split the argument into the IPv6 address and the device
    ipv6=$(echo "$1" | cut -d'_' -f1)
    device=$(echo "$1" | cut -d'_' -f2)

    echo "Starting ndp-fix.sh with:"
    echo "IP: $ipv6"
    echo "Device: $device"

    if ip -6 neighbor get "$ipv6" dev "$device" | grep -q "FAILED"; then
        echo "Error: $ipv6 host unreachable, exiting as it may be in maintenance"
        exit 0
    fi

    if ping "$ipv6"; then
        echo "$ipv6 is reachable, exiting"
        exit 0
    fi

    echo "Pinging $ipv6 failed, removing neighbor entry"
    remove_neighbor "$ipv6"

    if ping "$ipv6"; then
        echo "Pinging $ipv6 succeeded after removing neighbor entry, exiting"
        exit 0
    fi

    # wait 5 seconds before trying again
    sleep 5

    main "$1" $((count + 1))
}

if [ -z "$1" ]; then
    echo "Usage: $0 <ipv6>_<device>"
    exit 1
fi

# call the main function
main "$@"
