#!/bin/sh

if [ -z "$VPNADDR" -o -z "$VPNUSER" -o -z "$VPNPASS" ]; then
  echo "Variables VPNADDR, VPNUSER and VPNPASS must be set."; exit;
fi

export VPNTIMEOUT=${VPNTIMEOUT:-5}
export AUTO_RECONNECT=${AUTO_RECONNECT:-"true"}

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

if [ "$AUTO_RECONNECT" = "true" ]; then
  while [ true ]; do
    echo "------------ VPN Starts ------------"
    /usr/bin/forticlient
    echo "------------ VPN exited ------------"
    sleep 10
  done
else
  echo "------------ VPN Starts ------------"
  /usr/bin/forticlient
  if [ -z "$ON_EXIT_REPORT_SLACK" ]; then
    echo "------------ VPN exited ------------"
  else
    wget --no-check-certificate --quiet \
      --method POST \
      --timeout=0 \
      --header 'Content-Type: application/json' \
      --body-data "{\"text\": \"VPN exited ($VPNADDR/$VPNUSER)\"}" \
      "$ON_EXIT_REPORT_SLACK"
  fi
fi
